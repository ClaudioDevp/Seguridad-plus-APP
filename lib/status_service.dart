import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

class StatusService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> checkAndSendStatus(String userId) async {
    final ubicacionActiva = await _isLocationEnabled();
    final internetActivo = await _hasInternet();

    final data = {
      'ubicacion_activada': ubicacionActiva,
      'conectado_internet': internetActivo,
      'ultima_actualizacion': DateTime.now(),
    };

    await _firestore.collection('estado_usuarios').doc(userId).set(data);
  }

  Future<bool> _isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
