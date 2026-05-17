import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<UserCredential> signIn(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodGroup,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      bloodGroup: bloodGroup,
      role: role,
      createdAt: DateTime.now(),
    );

    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());

    return user;
  }

  Future<void> signOut() => _auth.signOut();


  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromDoc(doc);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}
