import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserLocation(String userId, double lat, double lng) {
    return _firestore.collection('ubicaciones').doc(userId).set({
      'latitud': lat,
      'longitud': lng,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> emitirAlerta(String userId) {
    return _firestore.collection('usuarios').doc(userId).update({
      'alerta_emitida': true,
      'timestamp_alerta': FieldValue.serverTimestamp(),
    });
  }
  Future<void> createUser(String userId, Map<String, dynamic> data) {
  return _firestore.collection('users').doc(userId).set(data);
}
}
