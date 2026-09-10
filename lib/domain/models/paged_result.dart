import 'package:freezed_annotation/freezed_annotation.dart';

part 'paged_result.freezed.dart';

/// One page of a longer list, plus whether more pages exist.
///
/// The product table is not loaded whole: the list requests fixed-size pages
/// and appends as the owner scrolls.
@freezed
class PagedResult<T> with _$PagedResult<T> {
  /// Creates a page.
  const factory PagedResult({
    required List<T> items,
    required int page,
    required bool hasMore,
  }) = _PagedResult<T>;

  const PagedResult._();

  /// An empty first page.
  static PagedResult<T> empty<T>() =>
      PagedResult<T>(items: <T>[], page: 0, hasMore: false);
}
