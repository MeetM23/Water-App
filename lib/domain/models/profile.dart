import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/account_status.dart';
import '../enums/user_role.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// A dealer or owner account as the database sees it.
///
/// [role] and [status] are authoritative: they are written only by the owner
/// through the approval RPCs and are enforced again by row level security on
/// every query. The client mirrors them to pick a route, not to grant access.
@freezed
class Profile with _$Profile {
  /// Creates a profile.
  const factory Profile({
    required String id,
    required UserRole role,
    required AccountStatus status,
    required String fullName,
    required String firmName,
    required String phone,
    required String city,
    required String state,
    required DateTime createdAt,
    String? gstNumber,
    String? address,
    DateTime? approvedAt,
    String? rejectionReason,
  }) = _Profile;

  const Profile._();

  /// Reads a profile row returned by Supabase.
  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  /// Whether this account may use the catalogue at all.
  bool get isApproved => switch (role) {
        UserRole.wholesaler || UserRole.owner => status == AccountStatus.approved,
        UserRole.retailer =>
          status != AccountStatus.rejected && status != AccountStatus.suspended,
      };
}
