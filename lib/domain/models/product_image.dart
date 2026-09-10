import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_image.freezed.dart';
part 'product_image.g.dart';

/// One photograph attached to a product.
///
/// [storagePath] points into the private product-images bucket. It is never a
/// URL: the app asks Supabase for a short-lived signed URL when it needs to
/// display the file.
@freezed
class ProductImage with _$ProductImage {
  /// Creates a product image record.
  const factory ProductImage({
    required String id,
    required String productId,
    required String storagePath,
    required int sortOrder,
    required bool isPrimary,
  }) = _ProductImage;

  const ProductImage._();

  /// Reads a product_images row.
  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);
}
