import 'package:freezed_annotation/freezed_annotation.dart';

import 'catalog_product.dart';

part 'catalogue_snapshot.freezed.dart';
part 'catalogue_snapshot.g.dart';

/// How long a cached catalogue may be shown before a live fetch is required.
///
/// Seven days is the brief. It is a real trade-off, not a round number: a
/// dealer quoting from a fortnight-old price list is worse than a dealer told
/// to find signal, and prices in this business move a few times a year.
const Duration catalogueCacheLifetime = Duration(days: 7);

/// A catalogue read, together with when it was read.
///
/// The timestamp is the whole point. A dealer standing in a godown with no
/// signal needs to know whether they are looking at this morning's prices or
/// last month's, and the banner cannot say so without this.
@freezed
class CatalogueSnapshot with _$CatalogueSnapshot {
  /// Creates a snapshot.
  const factory CatalogueSnapshot({
    required List<CatalogProduct> products,
    required DateTime fetchedAt,
  }) = _CatalogueSnapshot;

  const CatalogueSnapshot._();

  /// Reads a cached snapshot.
  factory CatalogueSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CatalogueSnapshotFromJson(json);

  /// Whether this snapshot is older than [catalogueCacheLifetime].
  ///
  /// [now] is a parameter rather than read from the clock so expiry is
  /// testable without waiting a week.
  bool isExpiredAt(DateTime now) =>
      now.difference(fetchedAt) > catalogueCacheLifetime;

  /// How old this snapshot is.
  Duration ageAt(DateTime now) => now.difference(fetchedAt);
}
