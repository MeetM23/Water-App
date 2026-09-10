import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/app_logger.dart';
import '../../domain/models/catalogue_snapshot.dart';
import '../../domain/repositories/catalogue_cache.dart';

part 'hive_catalogue_cache.g.dart';

/// Hive-backed offline storage for the dealer catalogue.
///
/// Three boxes, deliberately separate:
///
/// * `catalogue` holds one JSON blob and its timestamp. Storing the whole
///   catalogue as a single value rather than a row per product means a read is
///   one disk hit and a write is atomic — a half-written catalogue is not a
///   state a dealer in a godown can recover from.
/// * `catalogue_images` holds raw JPEG bytes keyed by STORAGE PATH. Not by
///   signed URL: those expire within the hour, so a URL-keyed cache misses on
///   every cold start, which is exactly when it is needed.
/// * `saved_products` holds the dealer's own list. It is not a cache and is
///   never cleared by "clear cache".
class HiveCatalogueCache implements CatalogueCache {
  /// Creates a cache. Call [initialise] before any other method.
  HiveCatalogueCache();

  static const String _catalogueBox = 'catalogue';
  static const String _imageBox = 'catalogue_images';
  static const String _savedBox = 'saved_products';

  static const String _snapshotKey = 'snapshot';

  Box<String>? _catalogue;
  Box<Uint8List>? _images;
  Box<String>? _saved;

  @override
  Future<void> initialise() async {
    _catalogue = await Hive.openBox<String>(_catalogueBox);
    _images = await Hive.openBox<Uint8List>(_imageBox);
    _saved = await Hive.openBox<String>(_savedBox);
  }

  @override
  CatalogueSnapshot? readCatalogue() {
    final raw = _catalogue?.get(_snapshotKey);
    if (raw == null) {
      return null;
    }
    try {
      return CatalogueSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object catch (error, stackTrace) {
      // A cache written by an older build with a different shape must not
      // crash the app on launch. Dropping it costs one refetch.
      AppLog.warn(
        'Discarding an unreadable catalogue cache',
        error,
        stackTrace,
      );
      final box = _catalogue;
      if (box != null) {
        unawaited(box.delete(_snapshotKey));
      }
      return null;
    }
  }

  @override
  Future<void> writeCatalogue(CatalogueSnapshot snapshot) async {
    await _catalogue?.put(_snapshotKey, jsonEncode(snapshot.toJson()));
  }

  @override
  Uint8List? readImage(String storagePath) => _images?.get(storagePath);

  @override
  Future<void> writeImage(String storagePath, Uint8List bytes) async {
    await _images?.put(storagePath, bytes);
  }

  @override
  List<String> readSavedCodes() =>
      _saved?.values.toList(growable: false) ?? const <String>[];

  @override
  Future<void> addSavedCode(String productCode) async {
    if (_saved == null || _saved!.values.contains(productCode)) {
      return;
    }
    // Auto-incrementing keys preserve the order the dealer saved things in,
    // which is the order a quotation reads best in.
    await _saved!.add(productCode);
  }

  @override
  Future<void> removeSavedCode(String productCode) async {
    final box = _saved;
    if (box == null) {
      return;
    }
    final keys = box.keys
        .where((dynamic key) => box.get(key) == productCode)
        .toList(growable: false);
    await box.deleteAll(keys);
  }

  @override
  Future<int> approximateSizeInBytes() async {
    var total = 0;
    for (final bytes in _images?.values ?? const <Uint8List>[]) {
      total += bytes.lengthInBytes;
    }
    final catalogue = _catalogue?.get(_snapshotKey);
    if (catalogue != null) {
      total += catalogue.length;
    }
    return total;
  }

  @override
  Future<void> clearCachedCatalogue() async {
    await _catalogue?.clear();
    await _images?.clear();
  }

  /// Number of products currently held offline.
  int get cachedProductCount => readCatalogue()?.products.length ?? 0;
}

/// The application-wide [CatalogueCache].
///
/// Deliberately unimplemented here. `main()` opens the Hive boxes before the
/// first frame and overrides this provider with the ready instance, so no
/// screen can ever reach a cache whose boxes are still opening — a race that
/// would surface as an empty catalogue on a slow phone rather than as an
/// error anybody would notice.
@Riverpod(keepAlive: true)
CatalogueCache catalogueCache(Ref<CatalogueCache> ref) =>
    throw UnimplementedError(
      'catalogueCacheProvider must be overridden in main() with an '
      'initialised HiveCatalogueCache',
    );

/// Products currently held in the offline cache, for the account screen.
@riverpod
CatalogueSnapshot? cachedCatalogueSnapshot(
  Ref<CatalogueSnapshot?> ref,
) => ref.watch(catalogueCacheProvider).readCatalogue();
