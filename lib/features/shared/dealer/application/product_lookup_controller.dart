import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/product_code.dart';
import '../../../../data/repositories/supabase_catalog_repository.dart';
import '../../../../data/repositories/supabase_unit_repository.dart';
import '../../../../domain/models/catalog_product.dart';
import '../../../../domain/models/product_unit.dart';
import 'catalogue_controller.dart';
import 'session_guard.dart';

part 'product_lookup_controller.g.dart';

/// The result of resolving a scanned or typed code.
sealed class LookupOutcome {
  const LookupOutcome();
}

/// The code resolved to a catalogue product model.
final class LookupFound extends LookupOutcome {
  /// Creates a successful catalogue lookup.
  const LookupFound(this.product);

  /// The product behind the code.
  final CatalogProduct product;
}

/// The code resolved to an individual physical RO machine unit.
final class LookupUnitFound extends LookupOutcome {
  /// Creates a successful physical unit lookup.
  const LookupUnitFound(this.unit);

  /// The physical unit behind the serial number.
  final ProductUnit unit;
}

/// The code is not a Maruti Water Solution code at all.
///
/// Either the shape is wrong or the check character disagrees. Both mean the
/// dealer scanned somebody else's barcode, which is by far the most common
/// failure in a shop full of other manufacturers' boxes.
final class LookupInvalidCode extends LookupOutcome {
  /// Creates an invalid-code outcome.
  const LookupInvalidCode();
}

/// The code is well formed but matches no product or unit.
final class LookupNotFound extends LookupOutcome {
  /// Creates a not-found outcome.
  const LookupNotFound();
}

/// The lookup itself could not be completed.
final class LookupFailed extends LookupOutcome {
  /// Creates a failed lookup.
  const LookupFailed(this.failure);

  /// Why it failed.
  final AppFailure failure;
}

/// Resolves a product code or unit serial number, offline first.
@riverpod
class ProductLookupController extends _$ProductLookupController {
  @override
  void build() {}

  /// Resolves [rawCode] as scanned or typed.
  Future<LookupOutcome> lookup(String rawCode) async {
    final code = ProductCode.normalise(rawCode);
    if (code == null) {
      return const LookupInvalidCode();
    }

    // 1. Physical machine serial lookup (MWS-SN-...)
    if (ProductCode.isUnitSerial(code)) {
      final result = await ref.read(unitRepositoryProvider).findUnitBySerial(code);
      final failure = result.failureOrNull;
      if (failure != null) {
        ref.read(sessionGuardProvider).handle(failure);
        return LookupFailed(failure);
      }
      final unit = result.valueOrNull;
      return unit == null ? const LookupNotFound() : LookupUnitFound(unit);
    }

    // 2. Catalogue product code lookup (MWS-DOM-...)
    final cached = ref.read(catalogueControllerProvider.notifier).findInLoaded(
      code,
    );
    if (cached != null) {
      return LookupFound(cached);
    }

    final result = await ref.read(catalogRepositoryProvider).findByCode(code);

    final failure = result.failureOrNull;
    if (failure != null) {
      ref.read(sessionGuardProvider).handle(failure);
      return LookupFailed(failure);
    }

    final product = result.valueOrNull;
    return product == null ? const LookupNotFound() : LookupFound(product);
  }
}

/// One product resolved by code, for the detail screen.
///
/// Offline-first for the same reason as the scanner: a dealer who scanned a
/// label with no signal must still see the product they scanned.
@riverpod
Future<CatalogProduct?> productByCode(
  Ref<AsyncValue<CatalogProduct?>> ref,
  String productCode,
) async {
  final outcome = await ref
      .read(productLookupControllerProvider.notifier)
      .lookup(productCode);

  return switch (outcome) {
    LookupFound(:final product) => product,
    LookupUnitFound() || LookupNotFound() || LookupInvalidCode() => null,
    LookupFailed(:final failure) => throw failure,
  };
}
