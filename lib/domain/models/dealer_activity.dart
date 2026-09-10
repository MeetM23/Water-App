/// How much a dealer has actually used the catalogue.
class DealerActivity {
  /// Creates an activity summary.
  const DealerActivity({required this.totalScans, this.lastActive});

  /// Every scan this dealer has ever recorded.
  final int totalScans;

  /// When they last scanned anything, or null if they never have.
  final DateTime? lastActive;

  /// An account approved but never used, which is worth a follow-up call.
  bool get hasNeverUsedTheApp => totalScans == 0;
}

/// One product in the most-scanned table.
class ScannedProduct {
  /// Creates a row.
  const ScannedProduct({
    required this.productId,
    required this.name,
    required this.productCode,
    required this.scanCount,
  });

  /// Which product was scanned.
  final String productId;

  /// Its name at the time of reading.
  final String name;

  /// Its permanent code.
  final String productCode;

  /// How many times it was scanned in the window.
  final int scanCount;
}

/// What happened to a dealer account, for the dashboard feed.
class DealerActivityEntry {
  /// Creates a feed entry.
  const DealerActivityEntry({
    required this.id,
    required this.action,
    required this.firmName,
    required this.fullName,
    required this.createdAt,
  });

  /// Audit row id.
  final String id;

  /// The audit action, such as `dealer.approved`.
  final String action;

  /// Firm the action concerned. Empty if the profile has since been removed.
  final String firmName;

  /// Contact name at that firm.
  final String fullName;

  /// When it happened.
  final DateTime createdAt;
}

/// Dealer headcounts for the dashboard.
class DealerCounts {
  /// Creates a counts snapshot.
  const DealerCounts({
    required this.pending,
    required this.wholesalers,
    required this.retailers,
    required this.suspended,
  });

  /// An empty snapshot, used before anything has loaded.
  static const DealerCounts zero = DealerCounts(
    pending: 0,
    wholesalers: 0,
    retailers: 0,
    suspended: 0,
  );

  /// Dealers awaiting a decision.
  final int pending;

  /// Approved wholesalers.
  final int wholesalers;

  /// Approved retailers.
  final int retailers;

  /// Suspended accounts of either role.
  final int suspended;
}
