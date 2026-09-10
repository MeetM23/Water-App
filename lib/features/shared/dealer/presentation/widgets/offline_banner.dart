import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/relative_time.dart';
import '../../application/catalogue_controller.dart';

/// Tells the dealer where the catalogue they are reading came from.
///
/// Renders nothing while the data is live and settled, so the grid keeps its
/// full height on a normal day. When the data is cached it says so, and when
/// the cache has passed its lifetime it says so loudly: a price quoted from a
/// week-old catalogue is a real loss to the dealer, not a cosmetic problem, and
/// they can only avoid it if they know.
class OfflineBanner extends ConsumerWidget {
  /// Creates the banner for [state].
  const OfflineBanner({required this.state, super.key});

  /// The catalogue state being described.
  final CatalogueState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!state.isOffline && !state.isRefreshing) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    // Through the provider rather than DateTime.now() so a test can walk the
    // clock past the seven-day boundary and see the warning change.
    final age = RelativeTime.format(
      l10n,
      state.fetchedAt,
      now: ref.watch(nowProvider)(),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (state.isExpired)
            _BannerRow(
              icon: Icons.warning_amber_rounded,
              accent: AppColors.warning,
              title: l10n.offlineExpiredTitle,
              message: l10n.offlineExpiredBody,
            )
          else if (state.isOffline)
            _BannerRow(
              icon: Icons.cloud_off_rounded,
              accent: AppColors.textSecondary,
              title: l10n.offlineBannerTitle,
              message: l10n.offlineBannerUpdated(age),
            ),
          if (state.isRefreshing) const _RefreshingRow(),
        ],
      ),
    );
  }
}

class _BannerRow extends StatelessWidget {
  const _BannerRow({
    required this.icon,
    required this.accent,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.x4,
        vertical: Spacing.x3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: Spacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(color: accent),
                ),
                const SizedBox(height: 2),
                // Left to wrap rather than clipped: the expired wording is the
                // whole point of the banner and truncating it would strip the
                // one sentence that explains why the price may be wrong.
                Text(
                  message,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshingRow extends StatelessWidget {
  const _RefreshingRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.x4,
        vertical: Spacing.x3,
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: Spacing.x3),
          Expanded(
            child: Text(
              context.l10n.offlineRefreshing,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
