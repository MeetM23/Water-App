// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$complaintDetailControllerHash() =>
    r'39415ac68ea94d60298b748abb831593b6f9400e';

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

abstract class _$ComplaintDetailController
    extends BuildlessAutoDisposeAsyncNotifier<Complaint> {
  late final String complaintId;

  FutureOr<Complaint> build(
    String complaintId,
  );
}

/// Loads single complaint details, timeline messages, and handles actions.
///
/// Copied from [ComplaintDetailController].
@ProviderFor(ComplaintDetailController)
const complaintDetailControllerProvider = ComplaintDetailControllerFamily();

/// Loads single complaint details, timeline messages, and handles actions.
///
/// Copied from [ComplaintDetailController].
class ComplaintDetailControllerFamily extends Family<AsyncValue<Complaint>> {
  /// Loads single complaint details, timeline messages, and handles actions.
  ///
  /// Copied from [ComplaintDetailController].
  const ComplaintDetailControllerFamily();

  /// Loads single complaint details, timeline messages, and handles actions.
  ///
  /// Copied from [ComplaintDetailController].
  ComplaintDetailControllerProvider call(
    String complaintId,
  ) {
    return ComplaintDetailControllerProvider(
      complaintId,
    );
  }

  @override
  ComplaintDetailControllerProvider getProviderOverride(
    covariant ComplaintDetailControllerProvider provider,
  ) {
    return call(
      provider.complaintId,
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
  String? get name => r'complaintDetailControllerProvider';
}

/// Loads single complaint details, timeline messages, and handles actions.
///
/// Copied from [ComplaintDetailController].
class ComplaintDetailControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ComplaintDetailController,
        Complaint> {
  /// Loads single complaint details, timeline messages, and handles actions.
  ///
  /// Copied from [ComplaintDetailController].
  ComplaintDetailControllerProvider(
    String complaintId,
  ) : this._internal(
          () => ComplaintDetailController()..complaintId = complaintId,
          from: complaintDetailControllerProvider,
          name: r'complaintDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$complaintDetailControllerHash,
          dependencies: ComplaintDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              ComplaintDetailControllerFamily._allTransitiveDependencies,
          complaintId: complaintId,
        );

  ComplaintDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.complaintId,
  }) : super.internal();

  final String complaintId;

  @override
  FutureOr<Complaint> runNotifierBuild(
    covariant ComplaintDetailController notifier,
  ) {
    return notifier.build(
      complaintId,
    );
  }

  @override
  Override overrideWith(ComplaintDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ComplaintDetailControllerProvider._internal(
        () => create()..complaintId = complaintId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        complaintId: complaintId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ComplaintDetailController, Complaint>
      createElement() {
    return _ComplaintDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ComplaintDetailControllerProvider &&
        other.complaintId == complaintId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, complaintId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ComplaintDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<Complaint> {
  /// The parameter `complaintId` of this provider.
  String get complaintId;
}

class _ComplaintDetailControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ComplaintDetailController,
        Complaint> with ComplaintDetailControllerRef {
  _ComplaintDetailControllerProviderElement(super.provider);

  @override
  String get complaintId =>
      (origin as ComplaintDetailControllerProvider).complaintId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
