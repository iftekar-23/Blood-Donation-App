
part of 'request_service.dart';

String _$requestServiceHash() => r'requestServiceHash';

@ProviderFor(requestService)
final requestServiceProvider = AutoDisposeProvider<RequestService>.internal(
  requestService,
  name: r'requestServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$requestServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RequestServiceRef = AutoDisposeProviderRef<RequestService>;
