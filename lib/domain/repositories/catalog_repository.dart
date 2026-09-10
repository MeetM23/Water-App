import 'dart:typed_data';

import '../../core/errors/result.dart';
import '../models/catalog_product.dart';

/// The dealer-facing catalogue.
///
/// Every method here reads `catalog_view` or `catalog_images_view`. Nothing in
/// this interface can reach the `products` table: that is enforced by row
/// level security, and mirrored here so the boundary is visible in the code as
/// well as in the database.
abstract interface class CatalogRepository {
  /// Loads the whole catalogue the caller is entitled to see.
  ///
  /// Unpaged on purpose. The catalogue is a few hundred rows at most, it has
  /// to be cached whole for offline use, and a dealer on 2G is better served
  /// by one request they can wait out than by twenty they cannot.
  Future<Result<List<CatalogProduct>>> fetchCatalogue();

  /// Looks up one product by its permanent code, for the scanner.
  ///
  /// Returns a null value (not a failure) when the code is well formed but
  /// matches nothing the caller may see.
  Future<Result<CatalogProduct?>> findByCode(String productCode);

  /// Storage paths of every image for a product, primary first.
  Future<Result<List<String>>> imagePathsFor(String productId);

  /// A short-lived signed URL for one stored image.
  Future<Result<String>> signedImageUrl(String storagePath);

  /// Downloads the bytes of one stored image, for the offline cache.
  Future<Result<Uint8List>> downloadImage(String storagePath);
}
