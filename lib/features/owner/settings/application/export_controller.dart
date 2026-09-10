import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../data/repositories/supabase_dealer_repository.dart';
import '../../../../data/repositories/supabase_product_repository.dart';
import '../../../../domain/enums/account_status.dart';
import '../../../../domain/models/business_settings.dart';
import '../../../../domain/models/profile.dart';
import '../data/catalogue_pdf_builder.dart';
import '../data/dealer_csv_builder.dart';
import 'business_settings_controller.dart';

part 'export_controller.g.dart';

/// A generated file waiting to be shared.
class ExportedFile {
  /// Creates an export result.
  const ExportedFile({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  /// The file contents.
  final Uint8List bytes;

  /// Suggested name, including the extension.
  final String fileName;

  /// MIME type for the share sheet.
  final String mimeType;
}

/// Which export is currently running, so only one button spins at a time.
enum ExportKind {
  /// The owner catalogue PDF.
  catalogue,

  /// The dealer list CSV.
  dealers,
}

/// Builds the catalogue and dealer exports.
///
/// Both are generated on demand rather than kept up to date in the background:
/// they are shared by WhatsApp within seconds of being made, so a stale copy is
/// worse than a two-second wait.
@riverpod
class ExportController extends _$ExportController {
  @override
  ExportKind? build() => null;

  /// Renders the owner catalogue, both price columns included.
  Future<({ExportedFile? file, AppFailure? failure})> catalogue() async {
    if (state != null) {
      return (file: null, failure: null);
    }
    state = ExportKind.catalogue;

    try {
      final products = await ref
          .read(productRepositoryProvider)
          .fetchAllForExport();

      final failure = products.failureOrNull;
      if (failure != null) {
        return (file: null, failure: failure);
      }

      // The business details head the document. If they cannot be read the
      // export still goes ahead with the defaults rather than failing: a price
      // list without a letterhead beats no price list.
      final business =
          ref.read(businessSettingsControllerProvider).valueOrNull ??
          const BusinessSettings(businessName: 'Maruti Water Solution');

      final generatedAt = DateTime.now();
      final bytes = await CataloguePdfBuilder.build(
        products: products.valueOrNull!,
        business: business,
        generatedAt: generatedAt,
      );

      return (
        file: ExportedFile(
          bytes: bytes,
          fileName: 'maruti-catalogue-${_stamp(generatedAt)}.pdf',
          mimeType: 'application/pdf',
        ),
        failure: null,
      );
    } finally {
      state = null;
    }
  }

  /// Renders the dealer list, every status included.
  Future<({ExportedFile? file, AppFailure? failure})> dealers() async {
    if (state != null) {
      return (file: null, failure: null);
    }
    state = ExportKind.dealers;

    try {
      final repository = ref.read(dealerRepositoryProvider);
      final collected = <Profile>[];

      // Every status, because the client uses this file to chase the accounts
      // that never got approved as much as the ones that did.
      for (final status in AccountStatus.values) {
        final page = await repository.fetchByStatus(status);
        final failure = page.failureOrNull;
        if (failure != null) {
          return (file: null, failure: failure);
        }
        collected.addAll(page.valueOrNull!);
      }

      collected.sort(
        (Profile a, Profile b) =>
            a.firmName.toLowerCase().compareTo(b.firmName.toLowerCase()),
      );

      return (
        file: ExportedFile(
          bytes: DealerCsvBuilder.build(collected),
          fileName: 'maruti-dealers-${_stamp(DateTime.now())}.csv',
          mimeType: 'text/csv',
        ),
        failure: null,
      );
    } finally {
      state = null;
    }
  }

  static String _stamp(DateTime moment) =>
      '${moment.year}'
      '-${moment.month.toString().padLeft(2, '0')}'
      '-${moment.day.toString().padLeft(2, '0')}';
}
