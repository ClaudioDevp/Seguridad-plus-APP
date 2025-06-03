import 'package:flutter/material.dart';

class LivekitProvider extends ChangeNotifier {
  String? _token;
  String? get token => _token;

  LivekitProvider();

  Future<void> setToken(String token) async {
    _token = token;
    notifyListeners();
  }
}
