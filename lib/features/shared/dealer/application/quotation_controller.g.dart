// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quotationControllerHash() =>
    r'c80ad57f63911e559ea6ce7a2e08ebd6b88fa1bf';

/// Turns the saved list into a quotation PDF.
///
/// One controller serves both dealer roles, because the job is the same one:
/// price the saved codes against the current catalogue and lay them out. The
/// [QuotationStyle] passed to [generate] is the only thing that differs, and it
/// arrives per call rather than being held, so the notifier has no role in it
/// to get out of step with the signed-in account.
///
/// The document is built on demand and never held: the saved list stores codes
/// and resolves prices against the current catalogue, so a sheet rendered five
/// minutes ago may already quote the wrong figure. Rebuilding costs a second
/// and is the only way the numbers are trustworthy.
///
/// Kept alive because a render outlives the tab: switching away mid-export
/// would dispose the notifier and the write of the finished flag would then
/// throw into a screen nobody is looking at.
///
/// Copied from [QuotationController].
@ProviderFor(QuotationController)
final quotationControllerProvider =
    NotifierProvider<QuotationController, bool>.internal(
  QuotationController.new,
  name: r'quotationControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quotationControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuotationController = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
