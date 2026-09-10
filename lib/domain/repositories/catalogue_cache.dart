import 'dart:typed_data';

import '../models/catalogue_snapshot.dart';

/// On-device storage for the catalogue, its images, and the saved list.
///
/// Backed by Hive. Everything here is synchronous-ish and local: no method on
/// this interface may touch the network, because every one of them is called
/// on a code path that has to work with no signal at all.
abstract interface class CatalogueCache {
  /// Opens the underlying boxes. Called once at startup.
  Future<void> initialise();

  /// The last catalogue written, or null if nothing has been cached yet.
  ///
  /// Returns the snapshot even when it is expired: deciding what to do about
  /// an old cache belongs to the controller, which can tell the difference
  /// between "stale but usable offline" and "too old to quote from".
  CatalogueSnapshot? readCatalogue();

  /// Replaces the cached catalogue and stamps it with [fetchedAt].
  Future<void> writeCatalogue(
    CatalogueSnapshot snapshot,
  );

  /// Cached bytes for one image storage path, or null.
  Uint8List? readImage(String storagePath);

  /// Stores the bytes of one image against its storage path.
  ///
  /// Keyed by storage path rather than by signed URL: signed URLs expire
  /// within the hour, so a URL-keyed cache misses on every cold start and is
  /// worthless precisely when it is needed.
  Future<void> writeImage(String storagePath, Uint8List bytes);

  /// Product codes the dealer has saved, in the order they saved them.
  List<String> readSavedCodes();

  /// Adds a product code to the saved list. A duplicate is a no-op.
  Future<void> addSavedCode(String productCode);

  /// Removes a product code from the saved list.
  Future<void> removeSavedCode(String productCode);

  /// Total bytes currently held on disk by the catalogue and image caches.
  ///
  /// Shown on the account screen so a dealer with a full phone can see what
  /// the app is costing them before deciding to clear it.
  Future<int> approximateSizeInBytes();

  /// Empties the catalogue and image caches.
  ///
  /// The saved list is deliberately NOT cleared: it is the dealer's own work,
  /// not a cache, and losing it to a "free up space" tap would be a bug.
  Future<void> clearCachedCatalogue();
}
