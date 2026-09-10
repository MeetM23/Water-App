// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scannerControllerHash() => r'4cfc4fb0a05f8e25e3c3eff989ffcce4de5e39c4';

/// Camera lifecycle, scan debouncing and code resolution.
///
/// The camera lives here rather than in the screen because the screen is a
/// tab: it stays mounted while the dealer is reading the catalogue, and the
/// camera must not stay powered while it is. Routing every start and stop
/// through one object means there is a single answer to "is the camera
/// running", which is what makes backgrounding mid-scan survivable.
///
/// Nothing here knows which role is scanning. Everything role-shaped, the
/// route to open and the price on the other side of it, is decided above.
///
/// Copied from [ScannerController].
@ProviderFor(ScannerController)
final scannerControllerProvider =
    AutoDisposeNotifierProvider<ScannerController, ScannerState>.internal(
  ScannerController.new,
  name: r'scannerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scannerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScannerController = AutoDisposeNotifier<ScannerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
