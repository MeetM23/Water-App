import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/dealer_segment.dart';

part 'dealer_query.freezed.dart';

/// Which slice of the dealer directory is on screen.
@freezed
class DealerQuery with _$DealerQuery {
  /// Creates a directory query.
  const factory DealerQuery({
    @Default(DealerSegment.all) DealerSegment segment,
    @Default('') String searchTerm,
  }) = _DealerQuery;

  const DealerQuery._();

  /// Whether a search term narrows the segment.
  bool get isSearching => searchTerm.trim().isNotEmpty;
}
