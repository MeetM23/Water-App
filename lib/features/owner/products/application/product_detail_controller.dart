import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/repositories/supabase_product_image_repository.dart';
import '../../../../data/repositories/supabase_product_repository.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/models/product_image.dart';

part 'product_detail_controller.g.dart';

/// A product together with everything the detail screen shows about it.
class ProductDetail {
  /// Creates a detail bundle.
  const ProductDetail({
    required this.product,
    required this.images,
    required this.scanCount,
  });

  /// The product itself.
  final Product product;

  /// Its photographs, primary first.
  final List<ProductImage> images;

  /// How many times a dealer has scanned it.
  final int scanCount;
}

/// Loads one product, its images and its scan count together.
@riverpod
class ProductDetailController extends _$ProductDetailController {
  @override
  Future<ProductDetail> build(String productId) async {
    final productResult = await ref
        .read(productRepositoryProvider)
        .fetchById(productId);

    final product = productResult.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw failure,
    );

    final imagesResult = await ref
        .read(productImageRepositoryProvider)
        .fetchForProduct(productId);
    final scanResult = await ref
        .read(productRepositoryProvider)
        .scanCount(productId);

    return ProductDetail(
      product: product,
      // Neither of these is worth failing the screen over: a product with an
      // unreadable image list is still worth showing.
      images: imagesResult.valueOrNull ?? <ProductImage>[],
      scanCount: scanResult.valueOrNull ?? 0,
    );
  }

  /// Reloads everything.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Resolves a signed URL for one stored image path.
///
/// The bucket is private, so nothing renders from a bare path. Kept as its own
/// provider so each tile fetches independently and a slow signature does not
/// hold up the rest of the gallery.
@riverpod
Future<String?> signedImageUrl(
  Ref<AsyncValue<String?>> ref,
  String path,
) async {
  final result = await ref.read(productImageRepositoryProvider).signedUrl(path);
  return result.valueOrNull;
}
