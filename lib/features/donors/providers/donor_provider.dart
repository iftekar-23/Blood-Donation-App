import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/models/user_model.dart';
import '../services/donor_service.dart';

part 'donor_provider.g.dart';

/// Currently selected blood group filter (empty = all)
@riverpod
class BloodGroupFilter extends _$BloodGroupFilter {
  @override
  String build() => '';

  void setFilter(String group) => state = group;
  void clearFilter() => state = '';
}

/// Stream of donors filtered by selected blood group
@riverpod
Stream<List<UserModel>> filteredDonors(FilteredDonorsRef ref) {
  final filter = ref.watch(bloodGroupFilterProvider);
  final service = ref.read(donorServiceProvider);
  return service.donorsStream(bloodGroup: filter.isEmpty ? null : filter);
}
