import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thanya/services/ESP32BluetoothService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";

  //  Bluetooth variables
  final ESP32BluetoothService _bluetoothService = ESP32BluetoothService();
  String receivedData = "";
  bool isConnected = false;
  bool isScanning = false;
  final TextEditingController _messageController = TextEditingController();

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        username = doc['name'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();


    _bluetoothService.dataStream.listen((data) {
      setState(() {
        receivedData = data;
      });
    });
  }

  Future<void> _connectToESP32() async {
    setState(() {
      isScanning = true;
    });
    await _bluetoothService.startScan();
    setState(() {
      isConnected = true;
      isScanning = false;
    });
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;
    _bluetoothService.sendData(message);
    _messageController.clear();
  }


  Future<void> _disconnect() async {
    await _bluetoothService.disconnect();
    setState(() {
      isConnected = false;
    });
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Hello $username!",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(text: "Save your life with us "),
                                    TextSpan(
                                      text: "THANYA",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Image.asset(
                        width: MediaQuery.of(context).size.width * 0.25,
                        'assets/logo1.png',
                      ),
                    ],
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),


          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHealthCard(
                      icon: Icons.favorite,
                      label: "Heart Rate",
                      value: "76 BPM",
                      color1: const Color(0xFFFF5252),
                      color2: const Color(0xFFF48FB1),
                    ),
                    _buildHealthCard(
                      icon: Icons.water_drop,
                      label: "Oxygen",
                      value: "98%",
                      color1: const Color(0xFF2196F3),
                      color2: const Color(0xFF64B5F6),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHealthCard(
                      icon: Icons.directions_walk,
                      label: "Steps",
                      value: "8,426",
                      color1: const Color(0xFFFF9800),
                      color2: const Color(0xFFFFCC80),
                    ),
                    _buildHealthCard(
                      icon: Icons.local_fire_department,
                      label: "Calories",
                      value: "312 kcal",
                      color1: const Color(0xFFFFC107),
                      color2: const Color(0xFFFFF176),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Bluetooth Connection",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: isConnected
                      ? _disconnect
                      : (isScanning ? null : _connectToESP32),
                  icon: Icon(
                    isConnected
                        ? Icons.bluetooth_disabled
                        : Icons.bluetooth_searching,
                  ),
                  label: Text(
                    isConnected
                        ? "Disconnect"
                        : (isScanning ? "Scanning..." : "Connect to ESP32"),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    isConnected ? Colors.red : Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    receivedData.isEmpty
                        ? "No data received yet."
                        : " Data: $receivedData",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: "Enter message to send",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isConnected ? _sendMessage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                      ),
                      child: const Text("Send"),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildHealthCard({
  required IconData icon,
  required String label,
  required String value,
  required Color color1,
  required Color color2,
}) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color1, blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
