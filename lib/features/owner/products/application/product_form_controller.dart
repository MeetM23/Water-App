import 'dart:io';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../data/repositories/supabase_product_image_repository.dart';
import '../../../../data/repositories/supabase_product_repository.dart';
import '../../../../domain/enums/product_category.dart';
import '../../../../domain/models/price_validation.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/models/product_draft.dart';
import '../../../../domain/models/product_image.dart';

part 'product_form_controller.g.dart';

/// Most photographs one product may carry.
const int maxProductImages = 6;

/// Owns the product form: its draft, its uploads, and its save.
///
/// Uploads land under a temporary storage prefix keyed by [_sessionId] and are
/// moved into place only on a successful save, so abandoning the form leaves
/// nothing behind in the bucket.
@riverpod
class ProductFormController extends _$ProductFormController {
  late final String _sessionId = _generateSessionId();
  ProductDraft _initial = const ProductDraft();

  @override
  Future<ProductDraft> build(String? productId) async {
    if (productId == null) {
      _initial = const ProductDraft();
      return _initial;
    }

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

    final images = imagesResult.fold(
      onSuccess: (value) => value
          .map(
            (ProductImage image) => DraftImage(
              id: image.id,
              storagePath: image.storagePath,
              isPrimary: image.isPrimary,
            ),
          )
          .toList(),
      onFailure: (_) => <DraftImage>[],
    );

    _initial = ProductDraft.fromProduct(
      product,
      images,
      _entriesFrom(product.specifications),
    );
    return _initial;
  }

  ProductDraft get _draft => state.value ?? const ProductDraft();

  void _update(ProductDraft draft) {
    state = AsyncValue<ProductDraft>.data(draft);
  }

  /// Whether anything has changed since the form opened.
  bool get isDirty {
    final current = state.valueOrNull;
    return current != null && current != _initial;
  }

  /// The current pricing verdict, recomputed on every keystroke.
  PriceValidation get priceValidation => PriceRules.check(
    wholesale: _draft.wholesalePrice,
    retail: _draft.retailPrice,
    mrp: _draft.mrp,
  );

  /// Whether the draft is complete enough to submit.
  bool get canSubmit =>
      _draft.name.trim().isNotEmpty &&
      _draft.category != null &&
      priceValidation.isValid &&
      !_draft.hasUploadsInFlight;

  /// Replaces the product name.
  void setName(String value) => _update(_draft.copyWith(name: value));

  /// Replaces the model number.
  void setModelNumber(String value) =>
      _update(_draft.copyWith(modelNumber: value));

  /// Replaces the description.
  void setDescription(String value) =>
      _update(_draft.copyWith(description: value));

  /// Replaces the capacity string.
  void setCapacity(String value) => _update(_draft.copyWith(capacity: value));

  /// Selects the category, which decides the product code prefix.
  void setCategory(ProductCategory category) =>
      _update(_draft.copyWith(category: category));

  /// Replaces the printed maximum retail price.
  void setMrp(String value) => _update(_draft.copyWith(mrp: value));

  /// Replaces the wholesale price.
  void setWholesalePrice(String value) =>
      _update(_draft.copyWith(wholesalePrice: value));

  /// Replaces the retail price.
  void setRetailPrice(String value) =>
      _update(_draft.copyWith(retailPrice: value));

  /// Sets the warranty length in months.
  void setWarrantyMonths(int months) =>
      _update(_draft.copyWith(warrantyMonths: months));

  /// Flips the in-stock flag.
  void setInStock({required bool value}) =>
      _update(_draft.copyWith(inStock: value));

  /// Sets the available stock quantity.
  void setStockQuantity(String value) =>
      _update(_draft.copyWith(stockQuantity: value));

  /// Flips the active flag.
  void setActive({required bool value}) =>
      _update(_draft.copyWith(isActive: value));

  /// Appends an empty specification row.
  void addSpecification() => _update(
    _draft.copyWith(
      specifications: <SpecificationEntry>[
        ..._draft.specifications,
        SpecificationEntry(id: _generateSessionId()),
      ],
    ),
  );

  /// Edits one specification row.
  void updateSpecification(String id, {String? key, String? value}) => _update(
    _draft.copyWith(
      specifications: _draft.specifications
          .map(
            (SpecificationEntry entry) => entry.id == id
                ? entry.copyWith(
                    key: key ?? entry.key,
                    value: value ?? entry.value,
                  )
                : entry,
          )
          .toList(),
    ),
  );

  /// Removes one specification row.
  void removeSpecification(String id) => _update(
    _draft.copyWith(
      specifications: _draft.specifications
          .where((SpecificationEntry entry) => entry.id != id)
          .toList(),
    ),
  );

  /// Compresses and uploads [file], appending it to the draft.
  ///
  /// The tile appears immediately with a progress value so the owner sees the
  /// work happening rather than a frozen sheet.
  Future<void> addImage(File file) async {
    if (_draft.images.length >= maxProductImages) {
      return;
    }

    final id = _generateSessionId();
    final placeholder = DraftImage(
      id: id,
      storagePath: '',
      isPrimary: _draft.images.isEmpty,
      isTemporary: true,
      uploadProgress: 0,
      localPath: file.path,
    );
    _update(
      _draft.copyWith(images: <DraftImage>[..._draft.images, placeholder]),
    );

    await _upload(id, file);
  }

  /// Retries an upload that failed, reusing the file already on the device.
  ///
  /// The picked file is still on disk, so a dropped connection costs the owner
  /// a tap rather than another trip through the camera.
  Future<void> retryImage(String id) async {
    final image = _draft.images.where((DraftImage i) => i.id == id).firstOrNull;
    if (image?.localPath == null) {
      return;
    }
    _replaceImage(
      id,
      (DraftImage current) =>
          current.copyWith(uploadProgress: 0, failureMessage: null),
    );
    await _upload(id, File(image!.localPath!));
  }

  Future<void> _upload(String id, File file) async {
    final result = await ref
        .read(productImageRepositoryProvider)
        .uploadTemporary(
          file,
          sessionId: _sessionId,
          onProgress: (double progress) => _setImageProgress(id, progress),
        );

    result.fold(
      onSuccess: (path) => _replaceImage(
        id,
        (DraftImage image) =>
            image.copyWith(storagePath: path, uploadProgress: 1),
      ),
      // The runtime type is a diagnostic, not a message: the tile shows a
      // localised string and offers the retry.
      onFailure: (failure) => _replaceImage(
        id,
        (DraftImage image) =>
            image.copyWith(failureMessage: failure.runtimeType.toString()),
      ),
    );
  }

  /// Removes an image from the draft, deleting it if it was only temporary.
  Future<void> removeImage(String id) async {
    final image = _draft.images.where((DraftImage i) => i.id == id).firstOrNull;
    if (image == null) {
      return;
    }

    final remaining = _draft.images
        .where((DraftImage i) => i.id != id)
        .toList();

    // Losing the primary must not leave the product without one.
    if (image.isPrimary && remaining.isNotEmpty) {
      remaining[0] = remaining.first.copyWith(isPrimary: true);
    }
    _update(_draft.copyWith(images: remaining));

    if (image.isTemporary && image.storagePath.isNotEmpty) {
      await ref.read(productImageRepositoryProvider).discardTemporary(<String>[
        image.storagePath,
      ]);
    }
  }

  /// Moves an image within the ordering.
  void reorderImages(int oldIndex, int newIndex) {
    final images = <DraftImage>[..._draft.images];
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    images.insert(target, images.removeAt(oldIndex));
    _update(_draft.copyWith(images: images));
  }

  /// Marks one image as the catalogue thumbnail.
  void setPrimaryImage(String id) => _update(
    _draft.copyWith(
      images: _draft.images
          .map((DraftImage image) => image.copyWith(isPrimary: image.id == id))
          .toList(),
    ),
  );

  /// Saves the draft and returns the stored product.
  ///
  /// Returns a failure instead of throwing so the form can stay populated: an
  /// owner who has typed a long specification list must never lose it because
  /// the network dropped.
  Future<({Product? product, AppFailure? failure})> save() async {
    final draft = _draft;
    final repository = ref.read(productRepositoryProvider);

    final saved = draft.isEditing
        ? await repository.update(draft)
        : await repository.create(draft);

    final failure = saved.failureOrNull;
    if (failure != null) {
      return (product: null, failure: failure);
    }

    final product = saved.valueOrNull!;

    final commit = await ref
        .read(productImageRepositoryProvider)
        .commitDraftImages(
          product.id,
          draft.images
              .where((DraftImage image) => image.storagePath.isNotEmpty)
              .map(
                (DraftImage image) => (
                  storagePath: image.storagePath,
                  isPrimary: image.isPrimary,
                  isTemporary: image.isTemporary,
                ),
              )
              .toList(),
        );

    final commitFailure = commit.failureOrNull;
    if (commitFailure != null) {
      return (product: product, failure: commitFailure);
    }

    _initial = draft;
    return (product: product, failure: null);
  }

  /// Deletes any upload that was never committed.
  Future<void> discardUploads() async {
    final orphans = _draft.images
        .where(
          (DraftImage image) =>
              image.isTemporary && image.storagePath.isNotEmpty,
        )
        .map((DraftImage image) => image.storagePath)
        .toList();

    if (orphans.isEmpty) {
      return;
    }
    await ref.read(productImageRepositoryProvider).discardTemporary(orphans);
  }

  void _setImageProgress(String id, double progress) => _replaceImage(
    id,
    (DraftImage image) => image.copyWith(uploadProgress: progress),
  );

  void _replaceImage(String id, DraftImage Function(DraftImage) transform) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    _update(
      current.copyWith(
        images: current.images
            .map(
              (DraftImage image) => image.id == id ? transform(image) : image,
            )
            .toList(),
      ),
    );
  }

  static List<SpecificationEntry> _entriesFrom(Map<String, dynamic> map) => map
      .entries
      .map(
        (MapEntry<String, dynamic> entry) => SpecificationEntry(
          id: '${entry.key}-${entry.value}',
          key: entry.key,
          value: '${entry.value}',
        ),
      )
      .toList();

  static String _generateSessionId() {
    final random = Random();
    final suffix = List<String>.generate(
      8,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    return '${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }
}
