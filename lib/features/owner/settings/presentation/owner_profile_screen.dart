import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/extensions/enum_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../domain/models/profile.dart';
import '../../../auth/application/session_controller.dart';

/// The owner's own account details.
///
/// Read-only apart from the password. The name, firm and phone on this record
/// are what the database uses to identify the owner, and letting them be typed
/// over from a settings screen would be an easy way to lock the client out of
/// their own audit trail for no real benefit.
class OwnerProfileScreen extends ConsumerWidget {
  /// Creates the screen.
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final profile = session is SessionSignedIn ? session.profile : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profile == null
          ? AppEmptyState(
              icon: Icons.person_outline_rounded,
              title: l10n.errorGenericTitle,
              message: l10n.errorGenericBody,
            )
          : ListView(
              padding: const EdgeInsets.all(Spacing.x4),
              children: <Widget>[
                _Identity(profile: profile),
                const SizedBox(height: Spacing.x5),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _Row(label: l10n.fieldPhone, value: profile.phone),
                      _Row(
                        label: l10n.labelCity,
                        value: '${profile.city}, ${profile.state}',
                      ),
                      _Row(
                        label: l10n.dealerAddressLabel,
                        value: profile.address?.trim().isNotEmpty ?? false
                            ? profile.address!
                            : l10n.dealerNoAddress,
                      ),
                      _Row(
                        label: l10n.dealerGstLabel,
                        value: profile.gstNumber?.trim().isNotEmpty ?? false
                            ? profile.gstNumber!
                            : l10n.dealerNoGst,
                      ),
                      _Row(
                        label: l10n.dealerRegisteredOn,
                        value: DateFormat.yMMMMd().format(profile.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.x5),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: Text(l10n.moreChangePassword),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(AppRoutes.ownerPassword),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          profile.fullName,
          style: context.textTheme.headlineSmall?.copyWith(
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: Spacing.x1),
        Text(
          profile.firmName,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.x3),
        AppBadge(label: profile.role.label(l10n), tone: AppBadgeTone.info),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
