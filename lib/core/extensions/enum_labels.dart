import '../../domain/enums/account_status.dart';
import '../../domain/enums/user_role.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/app_badge.dart';

/// Localised display names for [UserRole].
extension UserRoleLabel on UserRole {
  /// The name shown to the user.
  String label(AppLocalizations l10n) => switch (this) {
    UserRole.owner => l10n.roleOwner,
    UserRole.wholesaler => l10n.roleWholesaler,
    UserRole.retailer => l10n.roleRetailer,
  };
}

/// Localised display names and badge tones for [AccountStatus].
extension AccountStatusLabel on AccountStatus {
  /// The name shown to the user.
  String label(AppLocalizations l10n) => switch (this) {
    AccountStatus.pending => l10n.statusPending,
    AccountStatus.approved => l10n.statusApproved,
    AccountStatus.rejected => l10n.statusRejected,
    AccountStatus.suspended => l10n.statusSuspended,
  };

  /// The badge colour that matches this status.
  AppBadgeTone get tone => switch (this) {
    AccountStatus.pending => AppBadgeTone.warning,
    AccountStatus.approved => AppBadgeTone.success,
    AccountStatus.rejected => AppBadgeTone.danger,
    AccountStatus.suspended => AppBadgeTone.danger,
  };
}
