import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Timer? _timer;
  Position? _currentPosition;

  LocationProvider();

  /// Obtener la ubicación actual una sola vez
  Future<Position?> getCurrentLocation() async {
    final permissionGranted = await _checkAndRequestPermission();
    if (!permissionGranted) return null;

    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      print('❌ Error al obtener ubicación: $e');
      return null;
    }
  }

  /// Iniciar envío automático de ubicación a Firestore cada 10 segundos
  Future<void> startSendingLocation() async {
    final permissionGranted = await _checkAndRequestPermission();
    if (!permissionGranted) return;

    _timer?.cancel(); // Cancelar si ya había un envío previo

    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition();
        _currentPosition = position;
        await db.collection("users").doc(auth.currentUser!.uid).update({
          "lat": position.latitude,
          "lng": position.longitude,
        });
        print('📍 Ubicación enviada: ${position.latitude}, ${position.longitude}');
        notifyListeners();
      } catch (e) {
        print('❌ Error al enviar ubicación: $e');
      }
    });

    print("✅ Envío automático de ubicación iniciado.");
  }

  /// Detener envío automático
  void stopSendingLocation() {
    _timer?.cancel();
    print("⛔ Envío automático de ubicación detenido.");
  }

  /// Verificación de permisos
  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('⚠️ El GPS está apagado.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Permiso de ubicación denegado.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Permiso de ubicación denegado permanentemente.');
      return false;
    }

    return true;
  }

  /// Getter para usar la ubicación actual en el UI si querés
  Position? get currentPosition => _currentPosition;
}
