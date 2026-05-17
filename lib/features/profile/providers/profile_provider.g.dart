
part of 'profile_provider.dart';
String _$profileServiceHash() => r'profileServiceHash';

@ProviderFor(profileService)
final profileServiceProvider = AutoDisposeProvider<ProfileService>.internal(
  profileService,
  name: r'profileServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProfileServiceRef = AutoDisposeProviderRef<ProfileService>;
