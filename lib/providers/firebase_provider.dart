import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:seguridad_plus/models/alarm_model.dart';

class FirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreProvider();

  Future<String> emitirAlerta(String userId, String type) async {
    try {
      final response = await FirebaseFunctions.instance.httpsCallable("createCallRoom")();
      final alert = AlarmModel(type: type);
      await _db.collection("users").doc(userId).update({
        "alert": alert.toJson(),
        "alertTime": DateTime.now()
        });
      return response.data["token"];
    } catch (e, st) {
      print("❌ Error al emitir alerta: $e");
      print("📍 Stacktrace: $st");
      rethrow;
    }
  }
}
