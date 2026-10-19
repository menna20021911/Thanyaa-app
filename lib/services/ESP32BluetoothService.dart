import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ESP32BluetoothService {
  final FlutterBluePlus _bluetooth = FlutterBluePlus();
  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxChar;
  BluetoothCharacteristic? _txChar;

  final StreamController<String> _dataController =
  StreamController<String>.broadcast();

  Stream<String> get dataStream => _dataController.stream;


  String targetName = "ESP32_BLE";

  static const String SERVICE_UUID = "12345678-1234-1234-1234-123456789ABC";
  static const String CHARACTERISTIC_RECEIVE_UUID =
      "ABCD1234-5678-90AB-CDEF-1234567890AB";
  static const String CHARACTERISTIC_TRANSMIT_UUID =
      "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> startScan() async {
    bool granted = await _requestPermissions();
    if (!granted) {
      debugPrint("Bluetooth permissions not granted");
      return;
    }

    debugPrint("Scanning for ESP32...");
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name == targetName) {
          debugPrint(" Found ESP32: ${r.device.name}");
          await FlutterBluePlus.stopScan();
          _device = r.device;
          await connectToDevice();
          return;
        }
      }
    });
  }

  Future<void> connectToDevice() async {
    if (_device == null) return;

    debugPrint("Connecting to ESP32...");
    await _device!.connect(
      license: License.free,
      autoConnect: false,
      mtu: null,
      timeout: const Duration(seconds: 10),
    );
    debugPrint("Connected!");
    await discoverServices();
  }

  Future<void> discoverServices() async {
    if (_device == null) return;

    List<BluetoothService> services = await _device!.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == CHARACTERISTIC_RECEIVE_UUID) {
            _rxChar = c;
            await _rxChar!.setNotifyValue(true);
            _rxChar!.lastValueStream.listen((value) {
              String data = String.fromCharCodes(value);
              _dataController.add(data);
              debugPrint("Received from ESP32: $data");
            });
          } else if (c.uuid.toString() == CHARACTERISTIC_TRANSMIT_UUID) {
            _txChar = c;
          }
        }
      }
    }
  }

  Future<void> sendData(String message) async {
    if (_txChar == null) {
      debugPrint("TX characteristic not found!");
      return;
    }

    List<int> bytes = message.codeUnits;
    await _txChar!.write(bytes, withoutResponse: true);
    debugPrint("Sent to ESP32: $message");
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
    debugPrint("Disconnected from ESP32");
  }

  void dispose() {
    _dataController.close();
  }
}