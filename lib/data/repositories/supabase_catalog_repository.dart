import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/models/catalog_product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../supabase/supabase_providers.dart';

part 'supabase_catalog_repository.g.dart';

/// The dealer-facing catalogue, read from `catalog_view`.
///
/// This class never names the `products` table. It could not usefully do so:
/// the RLS policies in 0011 give a dealer zero rows there. The single price
/// column arrives already resolved from the caller's role inside the database,
/// so nothing here selects, filters or hides a price — there is only ever one.
class SupabaseCatalogRepository implements CatalogRepository {
  /// Creates a repository over an initialised client.
  SupabaseCatalogRepository(this._client);

  final SupabaseClient _client;

  static const String _view = 'catalog_view';
  static const String _imagesView = 'catalog_images_view';
  static const String _bucket = 'product-images';

  /// How long a display URL stays valid.
  static const int _signedUrlSeconds = 60 * 60;

  @override
  Future<Result<List<CatalogProduct>>> fetchCatalogue() async {
    try {
      final rows = await _client.from(_view).select().order('name');
      return Success<List<CatalogProduct>>(
        rows.map(CatalogProduct.fromJson).toList(),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<CatalogProduct>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<CatalogProduct?>> findByCode(String productCode) async {
    try {
      final row = await _client
          .from(_view)
          .select()
          .eq('product_code', productCode)
          .maybeSingle();

      // A null row is a legitimate answer, not a failure: the code was well
      // formed and simply matches nothing this dealer may see. The scanner
      // says so and keeps running.
      return Success<CatalogProduct?>(
        row == null ? null : CatalogProduct.fromJson(row),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure<CatalogProduct?>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<String>>> imagePathsFor(String productId) async {
    try {
      final rows = await _client
          .from(_imagesView)
          .select('storage_path')
          .eq('product_id', productId)
          .order('is_primary', ascending: false)
          .order('sort_order');

      return Success<List<String>>(<String>[
        for (final row in rows) row['storage_path'] as String,
      ]);
    } on Object catch (error, stackTrace) {
      return ResultFailure<List<String>>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<String>> signedImageUrl(String storagePath) async {
    try {
      final url = await _client.storage
          .from(_bucket)
          .createSignedUrl(storagePath, _signedUrlSeconds);
      return Success<String>(url);
    } on Object catch (error, stackTrace) {
      return ResultFailure<String>(_map(error, stackTrace));
    }
  }

  @override
  Future<Result<Uint8List>> downloadImage(String storagePath) async {
    try {
      final bytes = await _client.storage.from(_bucket).download(storagePath);
      return Success<Uint8List>(bytes);
    } on Object catch (error, stackTrace) {
      return ResultFailure<Uint8List>(_map(error, stackTrace));
    }
  }

  AppFailure _map(Object error, StackTrace stackTrace) {
    if (error is SocketException || error is HttpException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is StorageException) {
      // The storage read policy requires is_approved(). A dealer whose account
      // was just suspended gets a denial here rather than an empty list, which
      // makes this one of the two places the revocation surfaces.
      if (error.statusCode == '403' || error.statusCode == '401') {
        return SessionRevokedFailure(cause: error, stackTrace: stackTrace);
      }
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is PostgrestException) {
      if (error.code == '42501') {
        return PermissionFailure(cause: error, stackTrace: stackTrace);
      }
      return ServerFailure(cause: error, stackTrace: stackTrace);
    }
    AppLog.error('Unmapped catalog repository error', error, stackTrace);
    return UnexpectedFailure(cause: error, stackTrace: stackTrace);
  }
}

/// The application-wide [CatalogRepository].
@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref<CatalogRepository> ref) =>
    SupabaseCatalogRepository(ref.watch(supabaseClientProvider));
