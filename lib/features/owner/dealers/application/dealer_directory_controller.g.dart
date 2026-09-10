// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dealer_directory_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dealerQueryControllerHash() =>
    r'd360e5df0da3a788cadbdf5cc6a56ef6a80a8fe9';

/// Segment and search state for the dealer directory.
///
/// Copied from [DealerQueryController].
@ProviderFor(DealerQueryController)
final dealerQueryControllerProvider =
    AutoDisposeNotifierProvider<DealerQueryController, DealerQuery>.internal(
  DealerQueryController.new,
  name: r'dealerQueryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dealerQueryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DealerQueryController = AutoDisposeNotifier<DealerQuery>;
String _$dealerDirectoryControllerHash() =>
    r'59029355a2d3ac2f0bbd93992aaf9e09be443aa5';

/// Loads the directory slice the owner is currently looking at.
///
/// Copied from [DealerDirectoryController].
@ProviderFor(DealerDirectoryController)
final dealerDirectoryControllerProvider = AutoDisposeAsyncNotifierProvider<
    DealerDirectoryController, List<Profile>>.internal(
  DealerDirectoryController.new,
  name: r'dealerDirectoryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dealerDirectoryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DealerDirectoryController = AutoDisposeAsyncNotifier<List<Profile>>;
String _$dealerDetailControllerHash() =>
    r'595dad8356e6310ed086b7ffcebc50e661890b68';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DealerDetailController
    extends BuildlessAutoDisposeAsyncNotifier<DealerDetail> {
  late final String userId;

  FutureOr<DealerDetail> build(
    String userId,
  );
}

/// Loads one dealer with their scan totals.
///
/// Copied from [DealerDetailController].
@ProviderFor(DealerDetailController)
const dealerDetailControllerProvider = DealerDetailControllerFamily();

/// Loads one dealer with their scan totals.
///
/// Copied from [DealerDetailController].
class DealerDetailControllerFamily extends Family<AsyncValue<DealerDetail>> {
  /// Loads one dealer with their scan totals.
  ///
  /// Copied from [DealerDetailController].
  const DealerDetailControllerFamily();

  /// Loads one dealer with their scan totals.
  ///
  /// Copied from [DealerDetailController].
  DealerDetailControllerProvider call(
    String userId,
  ) {
    return DealerDetailControllerProvider(
      userId,
    );
  }

  @override
  DealerDetailControllerProvider getProviderOverride(
    covariant DealerDetailControllerProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dealerDetailControllerProvider';
}

/// Loads one dealer with their scan totals.
///
/// Copied from [DealerDetailController].
class DealerDetailControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DealerDetailController,
        DealerDetail> {
  /// Loads one dealer with their scan totals.
  ///
  /// Copied from [DealerDetailController].
  DealerDetailControllerProvider(
    String userId,
  ) : this._internal(
          () => DealerDetailController()..userId = userId,
          from: dealerDetailControllerProvider,
          name: r'dealerDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dealerDetailControllerHash,
          dependencies: DealerDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              DealerDetailControllerFamily._allTransitiveDependencies,
          userId: userId,
        );

  DealerDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  FutureOr<DealerDetail> runNotifierBuild(
    covariant DealerDetailController notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(DealerDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DealerDetailControllerProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DealerDetailController, DealerDetail>
      createElement() {
    return _DealerDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DealerDetailControllerProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DealerDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<DealerDetail> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _DealerDetailControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DealerDetailController,
        DealerDetail> with DealerDetailControllerRef {
  _DealerDetailControllerProviderElement(super.provider);

  @override
  String get userId => (origin as DealerDetailControllerProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
