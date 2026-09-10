import 'dart:io';

import '../../core/errors/result.dart';
import '../models/product_image.dart';

/// Storage and metadata for product photography.
abstract interface class ProductImageRepository {
  /// Lists the saved images for a product, primary first.
  Future<Result<List<ProductImage>>> fetchForProduct(String productId);

  /// Compresses and uploads [file] to a temporary prefix, reporting progress.
  ///
  /// The returned path is inside the temporary area; nothing is visible to the
  /// catalogue until [commitDraftImages] moves it.
  Future<Result<String>> uploadTemporary(
    File file, {
    required String sessionId,
    void Function(double progress)? onProgress,
  });

  /// Moves temporary uploads to their permanent product prefix and writes the
  /// product_images rows in their given order.
  Future<Result<void>> commitDraftImages(
    String productId,
    List<({String storagePath, bool isPrimary, bool isTemporary})> images,
  );

  /// Deletes objects that were uploaded but never committed.
  Future<Result<void>> discardTemporary(List<String> storagePaths);

  /// Removes every stored object belonging to a product.
  Future<Result<void>> deleteAllForProduct(String productId);

  /// Copies a product's objects under a new product, used when duplicating.
  Future<Result<void>> copyForDuplicate({
    required String sourceProductId,
    required String targetProductId,
  });

  /// Maps each id in [productIds] to the storage path of its primary photo.
  ///
  /// Products with no photograph are simply absent from the map. Fetched in
  /// one round trip per page so the catalogue list can show thumbnails without
  /// a query per row.
  Future<Result<Map<String, String>>> primaryPathsFor(List<String> productIds);

  /// Returns a short-lived signed URL for displaying [storagePath].
  Future<Result<String>> signedUrl(String storagePath);
}
