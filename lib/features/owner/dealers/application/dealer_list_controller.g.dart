// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dealer_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dealerListControllerHash() =>
    r'd3ecda345afa5e51d0110a31e885d3e22c58a1f5';

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

abstract class _$DealerListController
    extends BuildlessAutoDisposeAsyncNotifier<List<Profile>> {
  late final AccountStatus status;

  FutureOr<List<Profile>> build(
    AccountStatus status,
  );
}

/// Loads the dealers sitting in one approval state.
///
/// Copied from [DealerListController].
@ProviderFor(DealerListController)
const dealerListControllerProvider = DealerListControllerFamily();

/// Loads the dealers sitting in one approval state.
///
/// Copied from [DealerListController].
class DealerListControllerFamily extends Family<AsyncValue<List<Profile>>> {
  /// Loads the dealers sitting in one approval state.
  ///
  /// Copied from [DealerListController].
  const DealerListControllerFamily();

  /// Loads the dealers sitting in one approval state.
  ///
  /// Copied from [DealerListController].
  DealerListControllerProvider call(
    AccountStatus status,
  ) {
    return DealerListControllerProvider(
      status,
    );
  }

  @override
  DealerListControllerProvider getProviderOverride(
    covariant DealerListControllerProvider provider,
  ) {
    return call(
      provider.status,
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
  String? get name => r'dealerListControllerProvider';
}

/// Loads the dealers sitting in one approval state.
///
/// Copied from [DealerListController].
class DealerListControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DealerListController, List<Profile>> {
  /// Loads the dealers sitting in one approval state.
  ///
  /// Copied from [DealerListController].
  DealerListControllerProvider(
    AccountStatus status,
  ) : this._internal(
          () => DealerListController()..status = status,
          from: dealerListControllerProvider,
          name: r'dealerListControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dealerListControllerHash,
          dependencies: DealerListControllerFamily._dependencies,
          allTransitiveDependencies:
              DealerListControllerFamily._allTransitiveDependencies,
          status: status,
        );

  DealerListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final AccountStatus status;

  @override
  FutureOr<List<Profile>> runNotifierBuild(
    covariant DealerListController notifier,
  ) {
    return notifier.build(
      status,
    );
  }

  @override
  Override overrideWith(DealerListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DealerListControllerProvider._internal(
        () => create()..status = status,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DealerListController, List<Profile>>
      createElement() {
    return _DealerListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DealerListControllerProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DealerListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Profile>> {
  /// The parameter `status` of this provider.
  AccountStatus get status;
}

class _DealerListControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DealerListController,
        List<Profile>> with DealerListControllerRef {
  _DealerListControllerProviderElement(super.provider);

  @override
  AccountStatus get status => (origin as DealerListControllerProvider).status;
}

String _$dealerActionControllerHash() =>
    r'835ee7a9a740cb3c9bab470d2ce71433ada92c3f';

/// Runs the owner-only dealer decisions.
///
/// Each call reaches a SECURITY DEFINER routine that re-checks `is_owner()`
/// server side, so a compromised client cannot approve anybody. The loading
/// flag here is what keeps a double tap from firing two approvals.
///
/// Copied from [DealerActionController].
@ProviderFor(DealerActionController)
final dealerActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<DealerActionController, void>.internal(
  DealerActionController.new,
  name: r'dealerActionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dealerActionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DealerActionController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
