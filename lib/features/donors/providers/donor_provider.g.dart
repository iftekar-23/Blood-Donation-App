part of 'donor_provider.dart';
String _$filteredDonorsHash() => r'filteredDonorsHash';

@ProviderFor(filteredDonors)
final filteredDonorsAsync = AutoDisposeStreamProvider<List<UserModel>>.internal(
  filteredDonors,
  name: r'filteredDonorsAsync',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredDonorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredDonorsRef = AutoDisposeStreamProviderRef<List<UserModel>>;

String _$bloodGroupFilterHash() => r'bloodGroupFilterHash';

@ProviderFor(BloodGroupFilter)
final bloodGroupFilterProvider =
    AutoDisposeNotifierProvider<BloodGroupFilter, String>.internal(
  BloodGroupFilter.new,
  name: r'bloodGroupFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bloodGroupFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BloodGroupFilter = AutoDisposeNotifier<String>;
