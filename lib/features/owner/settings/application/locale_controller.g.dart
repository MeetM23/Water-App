// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localeControllerHash() => r'275a41cf7e1a5acb9f542d62a474a5b0efee4d92';

/// The language the app runs in.
///
/// Null means "follow the device", which is the right default: a phone already
/// set to Gujarati should not need the app told twice. Once the owner picks a
/// language explicitly, that choice wins and survives a restart, because the
/// most common reason to pick one is that the device language is not the one
/// the person actually reads.
///
/// Copied from [LocaleController].
@ProviderFor(LocaleController)
final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>.internal(
  LocaleController.new,
  name: r'localeControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localeControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleController = Notifier<Locale?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
