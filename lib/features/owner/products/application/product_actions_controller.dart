import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../data/repositories/supabase_product_image_repository.dart';
import '../../../../data/repositories/supabase_product_repository.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/models/product_draft.dart';
import 'product_list_controller.dart';

part 'product_actions_controller.g.dart';

/// The quick actions available on a product without opening the form.
///
/// Each one updates the loaded list in place on success, so the row reflects
/// the change immediately without refetching the whole page.
@riverpod
class ProductActionsController extends _$ProductActionsController {
  @override
  FutureOr<void> build() {}

  /// Flips whether dealers see the product as available.
  Future<AppFailure?> toggleStock(Product product) async {
    final result = await ref
        .read(productRepositoryProvider)
        .setInStock(product.id, inStock: !product.inStock);

    return result.fold(
      onSuccess: (updated) {
        ref
            .read(productListControllerProvider.notifier)
            .replaceInPlace(updated);
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  /// Flips whether the product appears in any dealer catalogue at all.
  Future<AppFailure?> toggleActive(Product product) async {
    final result = await ref
        .read(productRepositoryProvider)
        .setActive(product.id, isActive: !product.isActive);

    return result.fold(
      onSuccess: (updated) {
        ref
            .read(productListControllerProvider.notifier)
            .replaceInPlace(updated);
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  /// Copies a product, including its photographs.
  ///
  /// The copy gets its own product code from the database trigger: codes are
  /// never reused, so the duplicate is a genuinely separate item on a shelf.
  /// Storage objects are copied rather than shared, so deleting the original
  /// cannot strip the duplicate of its images.
  Future<({Product? product, AppFailure? failure})> duplicate(
    Product source,
  ) async {
    final draft = ProductDraft(
      name: source.name,
      modelNumber: source.modelNumber ?? '',
      description: source.description ?? '',
      capacity: source.capacity ?? '',
      category: source.category,
      mrp: source.mrp?.toString() ?? '',
      wholesalePrice: source.wholesalePrice.toString(),
      retailPrice: source.retailPrice.toString(),
      warrantyMonths: source.warrantyMonths ?? 12,
      inStock: source.inStock,
      isActive: source.isActive,
      specifications: <SpecificationEntry>[
        for (final entry in source.specifications.entries)
          SpecificationEntry(
            id: entry.key,
            key: entry.key,
            value: '${entry.value}',
          ),
      ],
    );

    final created = await ref.read(productRepositoryProvider).create(draft);
    final failure = created.failureOrNull;
    if (failure != null) {
      return (product: null, failure: failure);
    }

    final copy = created.valueOrNull!;
    await ref
        .read(productImageRepositoryProvider)
        .copyForDuplicate(sourceProductId: source.id, targetProductId: copy.id);

    await ref.read(productListControllerProvider.notifier).refresh();
    return (product: copy, failure: null);
  }

  /// Deletes a product and every stored object belonging to it.
  ///
  /// The images go first: a product row removed while its files survive leaves
  /// bytes nobody can reach or bill for correctly.
  Future<AppFailure?> delete(Product product) async {
    await ref
        .read(productImageRepositoryProvider)
        .deleteAllForProduct(product.id);

    final result = await ref.read(productRepositoryProvider).delete(product.id);

    return result.fold(
      onSuccess: (_) {
        ref
            .read(productListControllerProvider.notifier)
            .removeInPlace(product.id);
        return null;
      },
      onFailure: (failure) => failure,
    );
  }
}
