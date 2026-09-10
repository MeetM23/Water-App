import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/image_compressor.dart';
import '../../domain/models/product_image.dart';
import '../../domain/repositories/product_image_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_product_image_repository.g.dart';

/// Storage-backed product photography.
///
/// Uploads land under `tmp/` while the form is open and are moved to
/// `products/<id>/` only on save, so abandoning a form leaves the catalogue
/// prefix clean. The bucket is private throughout; display goes through
/// short-lived signed URLs.
class SupabaseProductImageRepository implements ProductImageRepository {
  /// Creates a repository over an initialised client.
  SupabaseProductImageRepository(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'product-images';
  static const String _temporaryPrefix = 'tmp';
  static const String _productPrefix = 'products';

  /// How long a display URL stays valid. Long enough to browse a catalogue,
  /// short enough that a leaked link expires.
  static const int _signedUrlSeconds = 60 * 60;

  @override
  Future<Result<List<ProductImage>>> fetchForProduct(String productId) async {
    try {
      final rows = await _client
          .from('product_images')
          .select()
          .eq('product_id', productId)
          .order('is_primary', ascending: false)
          .order('sort_order');
      return Success<List<ProductImage>>(
        rows.map(ProductImage.fromJson).toList(),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<ProductImage>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<String>> uploadTemporary(
    File file, {
    required String sessionId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      onProgress?.call(0.05);

      final compressed = await ImageCompressor.compress(file);
      if (compressed == null) {
        return const ResultFailure<String>(
          UnexpectedFailure(cause: 'Image could not be decoded'),
        );
      }

      // Compression is the measurable half of the work. The storage client
      // exposes no byte-level callback for the network half, so progress moves
      // to an indeterminate state here rather than inventing a percentage.
      onProgress?.call(0.5);

      final owner = _client.auth.currentUser?.id ?? 'unknown';
      final path =
          '$_temporaryPrefix/$owner/$sessionId/${_fileName(compressed)}';

      await _client.storage
          .from(_bucket)
          .upload(
            path,
            compressed,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      onProgress?.call(1);
      return Success<String>(path);
    } on Object catch (error, stackTrace) {
      return ResultFailure<String>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> commitDraftImages(
    String productId,
    List<({String storagePath, bool isPrimary, bool isTemporary})> images,
  ) async {
    try {
      final rows = <Map<String, dynamic>>[];

      for (var index = 0; index < images.length; index++) {
        final image = images[index];
        var path = image.storagePath;

        if (image.isTemporary) {
          path = '$_productPrefix/$productId/${path.split('/').last}';
          await _client.storage.from(_bucket).move(image.storagePath, path);
        }

        rows.add(<String, dynamic>{
          'product_id': productId,
          'storage_path': path,
          'sort_order': index,
          'is_primary': image.isPrimary,
        });
      }

      // Replacing wholesale keeps ordering and the single-primary index
      // consistent without diffing two lists.
      await _client.from('product_images').delete().eq('product_id', productId);
      if (rows.isNotEmpty) {
        await _client.from('product_images').insert(rows);
      }

      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> discardTemporary(List<String> storagePaths) async {
    if (storagePaths.isEmpty) {
      return const Success<void>(null);
    }
    try {
      await _client.storage.from(_bucket).remove(storagePaths);
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      // A failed cleanup must not block the user from leaving the form.
      AppLog.warn('Could not remove temporary uploads', error, stackTrace);
      return const Success<void>(null);
    }
  }

  @override
  Future<Result<void>> deleteAllForProduct(String productId) async {
    try {
      final objects = await _client.storage
          .from(_bucket)
          .list(path: '$_productPrefix/$productId');
      if (objects.isNotEmpty) {
        await _client.storage
            .from(_bucket)
            .remove(
              objects
                  .map((FileObject o) => '$_productPrefix/$productId/${o.name}')
                  .toList(),
            );
      }
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> copyForDuplicate({
    required String sourceProductId,
    required String targetProductId,
  }) async {
    try {
      final rows = await _client
          .from('product_images')
          .select()
          .eq('product_id', sourceProductId)
          .order('sort_order');

      final inserts = <Map<String, dynamic>>[];

      for (var index = 0; index < rows.length; index++) {
        final source = ProductImage.fromJson(rows[index]);
        final fileName = source.storagePath.split('/').last;
        final target = '$_productPrefix/$targetProductId/$fileName';

        // The objects are copied rather than shared, so deleting the original
        // product cannot strip the duplicate of its photography.
        await _client.storage.from(_bucket).copy(source.storagePath, target);

        inserts.add(<String, dynamic>{
          'product_id': targetProductId,
          'storage_path': target,
          'sort_order': index,
          'is_primary': source.isPrimary,
        });
      }

      if (inserts.isNotEmpty) {
        await _client.from('product_images').insert(inserts);
      }
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure<void>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Map<String, String>>> primaryPathsFor(
    List<String> productIds,
  ) async {
    if (productIds.isEmpty) {
      return const Success<Map<String, String>>(<String, String>{});
    }
    try {
      final rows = await _client
          .from('product_images')
          .select('product_id, storage_path')
          .inFilter('product_id', productIds)
          .eq('is_primary', true);

      return Success<Map<String, String>>(<String, String>{
        for (final row in rows)
          row['product_id'] as String: row['storage_path'] as String,
      });
    } on Object catch (error, stackTrace) {
      return ResultFailure<Map<String, String>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<String>> signedUrl(String storagePath) async {
    try {
      final url = await _client.storage
          .from(_bucket)
          .createSignedUrl(storagePath, _signedUrlSeconds);
      return Success<String>(url);
    } on Object catch (error, stackTrace) {
      return ResultFailure<String>(_map(error, stackTrace));
    }
  }

  static String _fileName(File file) {
    final segment = file.uri.pathSegments.last;
    return segment.toLowerCase().endsWith('.jpg') ? segment : '$segment.jpg';
  }

  AppFailure _map(Object error, StackTrace stackTrace) {
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is StorageException || error is PostgrestException) {
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    AppLog.error('Unmapped image repository error', error, stackTrace);
    return UnexpectedFailure(cause: error, stackTrace: stackTrace);
  }
}

/// The application-wide [ProductImageRepository].
@Riverpod(keepAlive: true)
ProductImageRepository productImageRepository(
  Ref<ProductImageRepository> ref,
) => SupabaseProductImageRepository(ref.watch(supabaseClientProvider));
