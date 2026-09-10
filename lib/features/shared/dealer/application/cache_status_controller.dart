import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/cache/hive_catalogue_cache.dart';

part 'cache_status_controller.g.dart';

/// What the offline catalogue currently costs this phone.
///
/// Three numbers rather than a formatted line, because the account screen has
/// to phrase them in the dealer's language and a controller has no localiser.
class CacheStatus {
  /// Creates a status snapshot.
  const CacheStatus({
    required this.productCount,
    required this.sizeInBytes,
    this.updatedAt,
  });

  /// Products currently held on disk. Zero when nothing has been downloaded.
  final int productCount;

  /// Bytes the cached catalogue and its images occupy.
  final int sizeInBytes;

  /// When the cached catalogue was last written, or null when there is none.
  final DateTime? updatedAt;

  /// Whether anything is on disk, and so whether clearing is worth offering.
  ///
  /// Phrased positively rather than as an `isEmpty`: the screen only ever asks
  /// the affirmative question, and a getter named `isEmpty` on something that
  /// is not a collection invites `!status.isEmpty` at every call site.
  bool get hasCachedProducts => productCount > 0;
}

/// Size and age of the offline catalogue, for the account screen.
///
/// Deliberately separate from the catalogue controller: this is the only place
/// that pays for the disk walk behind `approximateSizeInBytes`, and folding it
/// into the catalogue controller would make every catalogue load wait on a
/// measurement nobody outside this screen ever reads.
@riverpod
Future<CacheStatus> cacheStatus(Ref<AsyncValue<CacheStatus>> ref) async {
  final cache = ref.watch(catalogueCacheProvider);
  final snapshot = cache.readCatalogue();
  final bytes = await cache.approximateSizeInBytes();

  return CacheStatus(
    productCount: snapshot?.products.length ?? 0,
    sizeInBytes: bytes,
    updatedAt: snapshot?.fetchedAt,
  );
}
