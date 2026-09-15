import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../domain/models/business_settings.dart';
import '../../../../domain/models/product.dart';
import '../../labels/data/label_pdf_builder.dart';
import '../../labels/domain/label_sheet_spec.dart';
import '../../settings/application/business_settings_controller.dart';

/// Generation result holding both raw job items and compiled PDF bytes.
class LabelGenerationResult {
  const LabelGenerationResult({
    required this.jobItems,
    required this.pdfBytes,
  });

  final List<LabelJobItem> jobItems;
  final Uint8List pdfBytes;
}

/// Service class for batch generating product labels and compiling PDF.
class LabelGenerationService {
  const LabelGenerationService(this._ref);

  final Ref _ref;

  /// Batch generates product label items and compiles PDF bytes.
  Future<Result<LabelGenerationResult>> generateLabelsPdf({
    required List<Product> selectedProducts,
    required Map<String, int> quantities,
    required LabelSheetSpec spec,
    List<LabelJobItem>? existingJobItems,
  }) async {
    try {
      final jobItems = <LabelJobItem>[];

      if (existingJobItems != null && existingJobItems.isNotEmpty) {
        jobItems.addAll(existingJobItems);
      } else {
        for (final product in selectedProducts) {
          final qty = quantities[product.id] ?? 1;
          final code = (product.productCode.isNotEmpty) ? product.productCode : product.id;
          final serials = List<String>.generate(qty, (_) => code);
          jobItems.add(
            LabelJobItem(
              product: product,
              serialNumbers: serials,
            ),
          );
        }
      }

      BusinessSettings business;
      try {
        business = await _ref.read(businessSettingsControllerProvider.future);
      } catch (_) {
        business = const BusinessSettings(
          businessName: 'Maruti Water Solution',
        );
      }

      final pdfBytes = await LabelPdfBuilder.build(
        items: jobItems,
        spec: spec,
        business: business,
      );

      return Success<LabelGenerationResult>(
        LabelGenerationResult(
          jobItems: jobItems,
          pdfBytes: pdfBytes,
        ),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure<LabelGenerationResult>(
        UnexpectedFailure(cause: error, stackTrace: stackTrace),
      );
    }
  }
}

/// Provider for [LabelGenerationService].
final labelGenerationServiceProvider = Provider<LabelGenerationService>((ref) {
  return LabelGenerationService(ref);
});
