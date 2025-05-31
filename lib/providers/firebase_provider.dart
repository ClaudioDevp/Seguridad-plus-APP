import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreProvider();

  Future<void> emitirAlerta(String userId) async {
    try {
      
      print("✅ Alerta En emision: -------->");
      await _db.collection("users").doc(userId).set({
        'alert': true,
        'alert_time': DateTime.now(),
        'lat': -41.61951,
        'long': -73.60262,
        'municipality': 1,
      }).onError((e, _) => print("Error writing document: $e"));
      print("data.data()");
      // await _db.collection('users').doc(userId).set({
      //   'alert': true,
      //   'alert_time': FieldValue.serverTimestamp(),
      //   'lat': -41.61951,
      //   'long': -73.60262,
      //   'municipality': 1,
      // });

      print("✅ Alerta emitida correctamente");
    } catch (e, st) {
      print("❌ Error al emitir alerta: $e");
      print("📍 Stacktrace: $st");
      rethrow;
    }
  }
}
