import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthNotifierProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  User? get user => _user;

  AuthNotifierProvider() {
    // Escucha cambios en el usuario
    _auth.authStateChanges().listen((newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _user = credential.user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
