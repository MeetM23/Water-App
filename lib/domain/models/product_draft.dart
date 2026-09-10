import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/product_category.dart';
import 'product.dart';

part 'product_draft.freezed.dart';

/// A pending image on the product form.
///
/// While the form is open the file lives under a temporary storage prefix. It
/// is moved to its permanent path only when the product is saved, so a
/// cancelled form leaves nothing behind in the bucket.
@freezed
class DraftImage with _$DraftImage {
  /// Creates a draft image entry.
  const factory DraftImage({
    required String id,
    required String storagePath,
    required bool isPrimary,
    @Default(false) bool isTemporary,
    @Default(1.0) double uploadProgress,
    String? localPath,
    String? failureMessage,
  }) = _DraftImage;

  const DraftImage._();

  /// Whether the upload for this image is still running.
  bool get isUploading => uploadProgress < 1.0 && failureMessage == null;
}

/// One editable row of the specifications map.
///
/// Held as an ordered list rather than a map so the owner can type a key and a
/// value independently without rows jumping around as they type.
@freezed
class SpecificationEntry with _$SpecificationEntry {
  /// Creates a specification row.
  const factory SpecificationEntry({
    required String id,
    @Default('') String key,
    @Default('') String value,
  }) = _SpecificationEntry;

  const SpecificationEntry._();

  /// Whether this row carries anything worth saving.
  bool get isComplete => key.trim().isNotEmpty && value.trim().isNotEmpty;
}

/// Everything the product form holds while it is being edited.
///
/// [productCode] is present only when editing: it is issued by the database on
/// insert and is never constructed or guessed by the app.
@freezed
class ProductDraft with _$ProductDraft {
  /// Creates a draft.
  const factory ProductDraft({
    @Default('') String name,
    @Default('') String modelNumber,
    @Default('') String description,
    @Default('') String capacity,
    ProductCategory? category,
    @Default('') String mrp,
    @Default('') String wholesalePrice,
    @Default('') String retailPrice,
    @Default(12) int warrantyMonths,
    @Default(true) bool inStock,
    @Default(true) bool isActive,
    @Default(<SpecificationEntry>[]) List<SpecificationEntry> specifications,
    @Default(<DraftImage>[]) List<DraftImage> images,
    String? id,
    String? productCode,
  }) = _ProductDraft;

  const ProductDraft._();

  /// Builds a draft from an existing product and its saved images.
  factory ProductDraft.fromProduct(
    Product product,
    List<DraftImage> images,
    List<SpecificationEntry> specifications,
  ) => ProductDraft(
    id: product.id,
    productCode: product.productCode,
    name: product.name,
    modelNumber: product.modelNumber ?? '',
    description: product.description ?? '',
    capacity: product.capacity ?? '',
    category: product.category,
    mrp: product.mrp?.toString() ?? '',
    wholesalePrice: product.wholesalePrice.toString(),
    retailPrice: product.retailPrice.toString(),
    warrantyMonths: product.warrantyMonths ?? 12,
    inStock: product.inStock,
    isActive: product.isActive,
    specifications: specifications,
    images: images,
  );

  /// Whether this draft edits an existing product rather than creating one.
  bool get isEditing => id != null;

  /// Parsed wholesale price, or null when the field is empty or malformed.
  double? get wholesaleValue => double.tryParse(wholesalePrice.trim());

  /// Parsed retail price, or null when the field is empty or malformed.
  double? get retailValue => double.tryParse(retailPrice.trim());

  /// Parsed MRP, or null when the field is empty or malformed.
  double? get mrpValue => double.tryParse(mrp.trim());

  /// Absolute per-unit dealer margin, or null while either price is unusable.
  double? get dealerMargin {
    final wholesale = wholesaleValue;
    final retail = retailValue;
    if (wholesale == null || retail == null) {
      return null;
    }
    return retail - wholesale;
  }

  /// Dealer margin as a percentage of retail, or null when it cannot be shown.
  double? get dealerMarginPercent {
    final retail = retailValue;
    final margin = dealerMargin;
    if (retail == null || margin == null || retail <= 0) {
      return null;
    }
    return (margin / retail) * 100;
  }

  /// Completed specification rows collapsed into the jsonb payload.
  Map<String, dynamic> get specificationsMap => <String, dynamic>{
    for (final entry in specifications)
      if (entry.isComplete) entry.key.trim(): entry.value.trim(),
  };

  /// Whether any image is still uploading, which blocks save.
  bool get hasUploadsInFlight => images.any((DraftImage i) => i.isUploading);
}
