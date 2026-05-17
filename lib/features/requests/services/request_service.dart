import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../models/blood_request_model.dart';

part 'request_service.g.dart';

@riverpod
RequestService requestService(RequestServiceRef ref) => RequestService();

/// CRUD operations
class RequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create new blood request
  Future<void> createRequest(BloodRequestModel request) async {
    await _db
        .collection(AppConstants.requestsCollection)
        .add(request.toMap());
  }

  /// Stream all blood requests
  Stream<List<BloodRequestModel>> allRequestsStream() {
    return _db
        .collection(AppConstants.requestsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(BloodRequestModel.fromDoc).toList());
  }


  Stream<List<BloodRequestModel>> myRequestsStream(String uid) {
    return _db
        .collection(AppConstants.requestsCollection)
        .where('requesterId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(BloodRequestModel.fromDoc).toList());
  }


  Future<void> updateStatus(String requestId, String status) async {
    await _db
        .collection(AppConstants.requestsCollection)
        .doc(requestId)
        .update({'status': status});
  }

  /// Delete  request
  Future<void> deleteRequest(String requestId) async {
    await _db
        .collection(AppConstants.requestsCollection)
        .doc(requestId)
        .delete();
  }
}
