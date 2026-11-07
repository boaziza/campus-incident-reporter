import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

// Talks to Firebase Authentication and the users collection.
// No UI code here, the AuthProvider calls these methods.
class AuthService {
  AuthService._privateConstructor();

  static final AuthService instance = AuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name.trim());

    // Every new account is a student. Staff are promoted in the
    // Firebase console, the security rules block self-promotion.
    final appUser = AppUser(
      uid: user.uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
    );
    await _users.doc(user.uid).set(appUser.toFirestore());
    await user.sendEmailVerification();
  }

  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Firebase caches emailVerified, reload() fetches the latest value
  Future<bool> reloadAndCheckVerified() async {
    await _auth.currentUser?.reload();
    final verified = _auth.currentUser?.emailVerified ?? false;
    if (verified) {
      // Refresh the ID token so Firestore rules see email_verified = true
      await _auth.currentUser?.getIdToken(true);
    }
    return verified;
  }

  Stream<AppUser?> userProfile(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromFirestore(doc) : null,
        );
  }

  // Turns Firebase error codes into messages a student understands
  static String friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'weak-password':
          return 'Choose a stronger password.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'No internet connection.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
