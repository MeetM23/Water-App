import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../data/repositories/supabase_catalog_repository.dart';

part 'product_images_controller.g.dart';

/// Every image for one product, primary first, as storage paths.
///
/// Keyed by id and primary path rather than by the product object itself: a
/// silent catalogue refresh rebuilds every product object, and a family keyed
/// on the whole record would re-run this fetch — and re-download the gallery —
/// because a price moved by a rupee.
///
/// A failed listing is not an error state. The dealer this screen exists for
/// is often standing in a godown with no signal, where the only image that
/// will ever paint is the primary one already in the Hive cache. Showing them
/// an error instead of that one photo would be worse than showing nothing.
@riverpod
Future<List<String>> productImages(
  Ref<AsyncValue<List<String>>> ref,
  String productId,
  String? primaryImagePath,
) async {
  final result = await ref
      .read(catalogRepositoryProvider)
      .imagePathsFor(productId);

  final failure = result.failureOrNull;
  if (failure != null) {
    AppLog.warn('Could not list images for product $productId', failure);
    return _primaryOnly(primaryImagePath);
  }

  final paths = result.valueOrNull ?? const <String>[];
  return paths.isEmpty ? _primaryOnly(primaryImagePath) : paths;
}

List<String> _primaryOnly(String? primaryImagePath) => <String>[
  if (primaryImagePath != null) primaryImagePath,
];
