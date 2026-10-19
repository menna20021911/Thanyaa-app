import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User?> loginWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> registerUser(
    String name,
    String email,
    String bandId,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "BandID": bandId,
        "createdAt": DateTime.now(),
      });
    }
    return user;
  }

  Future<User?> loginWithGoogle() async {
    final googleProvider = GoogleAuthProvider();
    final credential = await _auth.signInWithProvider(googleProvider);
    return credential.user;
  }

  Future<User?> getCurrentUser() async {
    final user = _auth.currentUser;
    await user?.reload();
    return _auth.currentUser;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
