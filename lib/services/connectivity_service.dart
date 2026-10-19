// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _controller.stream;

  void initialize() {
    Connectivity().onConnectivityChanged.listen((result) {
      _controller.add(result != ConnectivityResult.none);
    });

    Connectivity().checkConnectivity().then((result) {
      _controller.add(result != ConnectivityResult.none);
    });
  }
}
