import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  final Connectivity _connectivity = Connectivity();

  InternetProvider() {
    _initialize();
  }

void _initialize() {
  _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
    final previousStatus = _isConnected;

    // Consider connected if any result is not none
    _isConnected = results.any((r) => r != ConnectivityResult.none);

    if (_isConnected != previousStatus) {
      notifyListeners();
    }
  });

  _checkInitialConnection();
}


Future<void> _checkInitialConnection() async {
  final results = await _connectivity.checkConnectivity();
  _isConnected = results.any((r) => r != ConnectivityResult.none);
  notifyListeners();
}
}
