import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../models/blood_request_model.dart';
import '../services/request_service.dart';

part 'request_provider.g.dart';
@riverpod
Stream<List<BloodRequestModel>> allRequests(AllRequestsRef ref) {
  return ref.read(requestServiceProvider).allRequestsStream();
}


@riverpod
Stream<List<BloodRequestModel>> myRequests(MyRequestsRef ref) {
  final uid = ref.read(authServiceProvider).currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(requestServiceProvider).myRequestsStream(uid);
}
