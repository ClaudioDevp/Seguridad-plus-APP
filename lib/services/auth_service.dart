import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';  // importa tu FirestoreService

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService firestoreService;

  AuthService({required this.firestoreService});

  Stream<User?> get userChanges => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user;
  }

  Future<User?> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user;

    if (user != null) {
      // Crear documento en Firestore 'users' con info básica
      await firestoreService.createUser(user.uid, {
        'email': email,
        'createdAt': DateTime.now(),
      });
    }
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
