import '../../core/errors/result.dart';
import '../enums/account_status.dart';
import '../enums/user_role.dart';
import '../models/dealer_activity.dart';
import '../models/dealer_query.dart';
import '../models/profile.dart';

/// Dealer network administration, owner only.
///
/// Every mutation goes through a SECURITY DEFINER routine that re-asserts
/// is_owner() in the database, so this interface cannot be used to escalate.
abstract interface class DealerRepository {
  /// Lists dealer profiles with the given status, newest first.
  Future<Result<List<Profile>>> fetchByStatus(AccountStatus status);

  /// Lists the directory slice described by [query].
  Future<Result<List<Profile>>> search(DealerQuery query);

  /// Loads one dealer profile.
  Future<Result<Profile>> fetchById(String userId);

  /// Counts dealers awaiting a decision, for the dashboard.
  Future<Result<int>> pendingCount();

  /// Headline dealer counts, in one round trip.
  Future<Result<DealerCounts>> counts();

  /// Scan totals for one dealer.
  Future<Result<DealerActivity>> activity(String userId);

  /// The most recent dealer decisions, newest first.
  Future<Result<List<DealerActivityEntry>>> recentActivity({int limit = 8});

  /// The email address behind a profile, for a password reset.
  Future<Result<String>> emailFor(String userId);

  /// Sends a Supabase password-reset email to [email].
  Future<Result<void>> sendPasswordReset(String email);

  /// Approves a dealer into [role].
  Future<Result<Profile>> approve(String userId, UserRole role);

  /// Rejects a dealer, recording [reason] for them to read.
  Future<Result<Profile>> reject(String userId, String reason);

  /// Moves an approved dealer between wholesaler and retailer.
  ///
  /// Separate from [approve] so repricing a dealer does not overwrite the date
  /// the relationship started.
  Future<Result<Profile>> setRole(String userId, UserRole role);

  /// Suspends an approved dealer.
  Future<Result<Profile>> suspend(String userId);

  /// Restores a suspended or rejected dealer.
  Future<Result<Profile>> reactivate(String userId);
}
