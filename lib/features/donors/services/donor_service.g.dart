part of 'donor_service.dart';

String _$donorServiceHash() => r'donorServiceHash';

@ProviderFor(donorService)
final donorServiceProvider = AutoDisposeProvider<DonorService>.internal(
  donorService,
  name: r'donorServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$donorServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DonorServiceRef = AutoDisposeProviderRef<DonorService>;
