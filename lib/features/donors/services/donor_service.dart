import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/models/user_model.dart';

part 'donor_service.g.dart';

@riverpod
DonorService donorService(DonorServiceRef ref) => DonorService();

class DonorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<UserModel>> donorsStream({String? bloodGroup}) {
    Query<Map<String, dynamic>> query = _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.roleDonor)
        .where('isAvailable', isEqualTo: true);

    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }

    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => UserModel.fromDoc(doc))
              .toList(),
        );
  }


  Future<void> setAvailability(String uid, bool available) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'isAvailable': available});
  }
}
