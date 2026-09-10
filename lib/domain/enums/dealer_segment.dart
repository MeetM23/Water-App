import '../enums/account_status.dart';
import '../enums/user_role.dart';

/// The segmented control across the top of the dealer directory.
///
/// A segment is a saved question the owner asks constantly ("who are my
/// wholesalers?"), not a raw status filter, which is why "All" means every
/// approved dealer rather than literally every row: a suspended account is a
/// different conversation and has its own segment.
enum DealerSegment {
  /// Every approved dealer, both roles.
  all,

  /// Approved wholesalers only.
  wholesalers,

  /// Approved retailers only.
  retailers,

  /// Suspended accounts, either role.
  suspended,
}

/// Maps a segment onto the status and role it selects.
extension DealerSegmentQuery on DealerSegment {
  /// Account status this segment shows.
  AccountStatus get status => switch (this) {
    DealerSegment.all ||
    DealerSegment.wholesalers ||
    DealerSegment.retailers => AccountStatus.approved,
    DealerSegment.suspended => AccountStatus.suspended,
  };

  /// Role this segment narrows to, or null for both.
  UserRole? get role => switch (this) {
    DealerSegment.wholesalers => UserRole.wholesaler,
    DealerSegment.retailers => UserRole.retailer,
    DealerSegment.all || DealerSegment.suspended => null,
  };
}
