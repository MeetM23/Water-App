import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/cache/hive_catalogue_cache.dart';
import '../../../../domain/models/catalog_product.dart';
import 'catalogue_controller.dart';

part 'saved_controller.g.dart';

/// The dealer's own shortlist, stored on the device.
///
/// Codes are persisted, not whole products. A saved entry then always reflects
/// the current price and stock rather than whatever they were on the day it
/// was saved, which matters because the list's whole purpose is being turned
/// into a quotation.
@Riverpod(keepAlive: true)
class SavedController extends _$SavedController {
  @override
  List<String> build() => ref.watch(catalogueCacheProvider).readSavedCodes();

  /// Whether [productCode] is on the list.
  bool contains(String productCode) => state.contains(productCode);

  /// Adds a product to the list.
  Future<void> save(String productCode) async {
    if (state.contains(productCode)) {
      return;
    }
    await ref.read(catalogueCacheProvider).addSavedCode(productCode);
    state = <String>[...state, productCode];
  }

  /// Removes a product from the list.
  Future<void> remove(String productCode) async {
    await ref.read(catalogueCacheProvider).removeSavedCode(productCode);
    state = state.where((String code) => code != productCode).toList();
  }

  /// Adds or removes, returning true when the product ended up saved.
  Future<bool> toggle(String productCode) async {
    if (state.contains(productCode)) {
      await remove(productCode);
      return false;
    }
    await save(productCode);
    return true;
  }
}

/// The saved codes resolved against the loaded catalogue.
///
/// A saved code with no matching product is dropped rather than rendered as a
/// blank row: the owner may have deactivated the product since it was saved,
/// and a quotation must not carry a line nobody can supply.
@riverpod
List<CatalogProduct> savedProducts(Ref<List<CatalogProduct>> ref) {
  final codes = ref.watch(savedControllerProvider);
  final catalogue = ref.watch(catalogueControllerProvider).valueOrNull;
  if (catalogue == null) {
    return const <CatalogProduct>[];
  }

  final byCode = <String, CatalogProduct>{
    for (final product in catalogue.products) product.productCode: product,
  };

  return <CatalogProduct>[
    for (final code in codes)
      if (byCode[code] != null) byCode[code]!,
  ];
}
