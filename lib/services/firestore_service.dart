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

  Future<void> emitirAlerta(String userId) async {
    try {
      
      await _firestore.collection('users').doc(userId).set({
        'alert': true,
        'alert_time': FieldValue.serverTimestamp(),
        'lat': -41.61951,
        'long': -73.60262,
        'municipality': 1,
      }, SetOptions(merge: true));

      print("✅ Alerta emitida correctamente");
    } catch (e, st) {
      print("❌ Error al emitir alerta: $e");
      print("📍 Stacktrace: $st");
      rethrow;
    }
  }

  Future<void> linkRoomName(String userId, String roomName) async {
    print("$userId $roomName");
    await _firestore.collection('users').doc(userId).update({
      'roomName': roomName,
    });
  }

  Future<void> createUser(String userId, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(userId).set(data);
  }
}
