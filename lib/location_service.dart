// ignore_for_file: avoid_print

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;

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

    // Empieza a enviar la ubicación cada 10 segundos
    _timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition();
        await _firestore.collection('ubicaciones').doc('usuario_1').set({
          'latitud': position.latitude,
          'longitud': position.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        });

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
