import '../../core/errors/result.dart';
import '../enums/user_role.dart';

/// Where a scan came from, mirroring the `source` check on scan_events.
enum ScanSource {
  /// Read off a label by the camera.
  camera,

  /// Typed in by hand through the manual-entry fallback.
  manual,
}

/// Records that a dealer looked a product up.
///
/// This is telemetry for the owner, not part of the lookup. Every call is fire
/// and forget: a dealer holding a phone at a barcode must never wait on an
/// insert, and must never be told a scan failed because the logging did.
abstract interface class ScanRepository {
  /// Records one successful scan.
  ///
  /// Returns a [Result] so a caller that wants to know can look, but the
  /// scanner deliberately ignores it.
  /// [role] is recorded alongside the event so the owner can tell wholesaler
  /// traffic from retailer traffic. It is passed in rather than read here
  /// because the session lives above the data layer, and a repository that
  /// reached up into it would invert the dependency for one column.
  Future<Result<void>> logScan({
    required String productId,
    required ScanSource source,
    required UserRole role,
  });
}
