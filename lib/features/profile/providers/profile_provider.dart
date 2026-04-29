import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileService profileService(ProfileServiceRef ref) => ProfileService();

/// Handles profile image upload and profile updates
class ProfileService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image and return download URL
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');
    final task = await ref.putFile(imageFile);
    return task.ref.getDownloadURL();
  }
}
