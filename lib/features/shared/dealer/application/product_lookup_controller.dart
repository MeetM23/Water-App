import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/product_code.dart';
import '../../../../data/repositories/supabase_catalog_repository.dart';
import '../../../../data/repositories/supabase_product_registration_repository.dart';
import '../../../../domain/models/catalog_product.dart';
import '../../../../domain/models/product_lookup.dart';
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

/// The code resolved to a product registration / lookup model.
final class LookupUnitFound extends LookupOutcome {
  /// Creates a successful product lookup.
  const LookupUnitFound(this.unit);

  /// The product lookup result.
  final ProductLookup unit;
}

/// The code is not a Maruti Water Solution code at all.
final class LookupInvalidCode extends LookupOutcome {
  /// Creates an invalid-code outcome.
  const LookupInvalidCode();
}

/// The code is well formed but matches no product.
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

/// Resolves a product code or barcode, offline first.
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

    // 1. Product barcode & registration lookup
    final result = await ref.read(productRegistrationRepositoryProvider).findProductByBarcode(code);
    final failure = result.failureOrNull;
    if (failure != null) {
      ref.read(sessionGuardProvider).handle(failure);
      return LookupFailed(failure);
    }
    final unit = result.valueOrNull;
    if (unit != null) {
      return LookupUnitFound(unit);
    }

    // 2. Catalogue product code lookup fallback
    final cached = ref.read(catalogueControllerProvider.notifier).findInLoaded(
      code,
    );
    if (cached != null) {
      return LookupFound(cached);
    }

    final catResult = await ref.read(catalogRepositoryProvider).findByCode(code);

    final catFailure = catResult.failureOrNull;
    if (catFailure != null) {
      ref.read(sessionGuardProvider).handle(catFailure);
      return LookupFailed(catFailure);
    }

    final product = catResult.valueOrNull;
    return product == null ? const LookupNotFound() : LookupFound(product);
  }
}

/// One product resolved by code, for the detail screen.
@riverpod
Future<CatalogProduct?> productByCode(
  Ref<AsyncValue<CatalogProduct?>> ref,
  String productCode,
) async {
  final cleanCode = ProductCode.normalise(productCode) ?? productCode.trim().toUpperCase();

  // 1. Check loaded catalogue cache
  final cached = ref.read(catalogueControllerProvider.notifier).findInLoaded(cleanCode);
  if (cached != null) {
    return cached;
  }

  // 2. Fetch real CatalogProduct from catalogRepositoryProvider (catalog_view)
  final catResult = await ref.read(catalogRepositoryProvider).findByCode(cleanCode);
  final catFailure = catResult.failureOrNull;
  if (catFailure != null) {
    ref.read(sessionGuardProvider).handle(catFailure);
    throw catFailure;
  }

  final catProduct = catResult.valueOrNull;
  if (catProduct != null) {
    return catProduct;
  }

  // 3. Fallback to product/unit barcode lookup
  final outcome = await ref
      .read(productLookupControllerProvider.notifier)
      .lookup(cleanCode);

  return switch (outcome) {
    LookupFound(:final product) => product,
    LookupUnitFound(:final unit) => ref
        .read(catalogueControllerProvider.notifier)
        .findInLoaded(unit.productCode ?? unit.serialNumber),
    LookupNotFound() || LookupInvalidCode() => null,
    LookupFailed(:final failure) => throw failure,
  };
}
