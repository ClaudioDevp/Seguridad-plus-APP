// ignore_for_file: avoid_print

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import './firestore_service.dart';

class LocationService {
  final FirestoreService firestoreService;
  Timer? _timer;
  LocationService({required this.firestoreService});

  Future<void> startSendingLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('El GPS está apagado.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permiso de ubicación denegado.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permiso de ubicación denegado permanentemente.');
      return;
    }

    // Empieza a enviar la ubicación cada 15 segundos
    _timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition();
        await firestoreService.saveUserLocation("usuario_1", position.latitude, position.longitude);
        print('Ubicación enviada: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        print('Error al obtener ubicación: $e');
      }
    });

    print("🚗 Envío automático de ubicación iniciado.");
  }

  void stopSendingLocation() {
    _timer?.cancel();
    print("⛔ Envío automático de ubicación detenido.");
  }
}
