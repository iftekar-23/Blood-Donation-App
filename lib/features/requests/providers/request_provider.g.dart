// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allRequestsHash() => r'allRequestsHash';

/// See also [allRequests].
@ProviderFor(allRequests)
final allRequestsProvider =
    AutoDisposeStreamProvider<List<BloodRequestModel>>.internal(
  allRequests,
  name: r'allRequestsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllRequestsRef = AutoDisposeStreamProviderRef<List<BloodRequestModel>>;

String _$myRequestsHash() => r'myRequestsHash';

/// See also [myRequests].
@ProviderFor(myRequests)
final myRequestsProvider =
    AutoDisposeStreamProvider<List<BloodRequestModel>>.internal(
  myRequests,
  name: r'myRequestsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyRequestsRef = AutoDisposeStreamProviderRef<List<BloodRequestModel>>;
