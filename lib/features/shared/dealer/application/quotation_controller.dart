import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../domain/models/business_settings.dart';
import '../../../owner/settings/application/business_settings_controller.dart';
import '../data/quotation_pdf_builder.dart';
import '../domain/dealer_experience.dart';
import 'catalogue_controller.dart';
import 'saved_controller.dart';

part 'quotation_controller.g.dart';

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
@Riverpod(keepAlive: true)
class QuotationController extends _$QuotationController {
  Future<Uint8List?>? _inFlight;

  /// Whether a document is being rendered right now.
  @override
  bool build() => false;

  /// Renders the quotation, or null when it could not be built.
  ///
  /// Failures come back as a null rather than as a thrown [Object]: none of
  /// them is anything the dealer can act on differently, so the screen says
  /// one plain thing and the saved list is left exactly as it was.
  Future<Uint8List?> generate(QuotationStyle style) async {
    // Loading the fonts and laying out the table take long enough that a
    // second tap can land before the button has repainted as busy. Both
    // callers wait on the one job rather than rendering the sheet twice.
    final running = _inFlight;
    if (running != null) {
      return running;
    }

    final job = _render(style);
    _inFlight = job;
    try {
      return await job;
    } finally {
      _inFlight = null;
    }
  }

  Future<Uint8List?> _render(QuotationStyle style) async {
    state = true;
    try {
      final products = ref.read(savedProductsProvider);
      if (products.isEmpty) {
        return null;
      }

      return await QuotationPdfBuilder.build(
        products: products,
        business: await _business(),
        style: style,
        generatedAt: ref.read(nowProvider)(),
      );
    } on Object catch (error, stackTrace) {
      AppLog.error('Building the quotation failed', error, stackTrace);
      return null;
    } finally {
      state = false;
    }
  }

  /// The letterhead details, falling back to the client's name alone.
  ///
  /// A dealer builds a quotation standing in someone else's shop, often with
  /// no signal. A settings row that will not load must not sink the document:
  /// a quotation under a bare letterhead beats no quotation at all.
  Future<BusinessSettings> _business() async {
    try {
      return await ref.read(businessSettingsControllerProvider.future);
    } on Object catch (error, stackTrace) {
      AppLog.warn(
        'Business details unavailable, quoting under the default letterhead',
        error,
        stackTrace,
      );
      return const BusinessSettings(businessName: _fallbackBusinessName);
    }
  }

  /// The name the shared file is offered under.
  ///
  /// Dated, because a dealer sends several of these in a week and an undated
  /// name turns their WhatsApp history into a column of identical files.
  static String fileNameFor(DateTime generatedAt) =>
      'maruti-quotation-${_stamp(generatedAt)}.pdf';

  static const String _fallbackBusinessName = 'Maruti Water Solution';

  static String _stamp(DateTime moment) =>
      '${moment.year}'
      '-${moment.month.toString().padLeft(2, '0')}'
      '-${moment.day.toString().padLeft(2, '0')}';
}
