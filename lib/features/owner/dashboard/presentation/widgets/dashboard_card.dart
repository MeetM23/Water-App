import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_skeleton.dart';

/// Renders one dashboard section from its own provider.
///
/// The dashboard is five independent queries. Wrapping each in this widget is
/// what makes a failure local: a scan-analytics outage leaves an inline retry
/// in one card while the pending count above it still answers the question the
/// owner actually opened the app to ask.
class DashboardCard<T> extends ConsumerWidget {
  /// Creates a card bound to [value].
  const DashboardCard({
    required this.value,
    required this.builder,
    required this.onRetry,
    required this.skeletonHeight,
    super.key,
  });

  /// The provider's current state.
  final AsyncValue<T> value;

  /// Builds the loaded content.
  final Widget Function(BuildContext context, T data) builder;

  /// Reloads just this card.
  final VoidCallback onRetry;

  /// Height of the shimmer stand-in, so the layout does not jump on load.
  final double skeletonHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return value.when(
      loading: () => AppShimmer(child: AppSkeleton(height: skeletonHeight)),
      error: (Object error, StackTrace stackTrace) =>
          _CardError(onRetry: onRetry, height: skeletonHeight),
      data: (T data) => builder(context, data),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({required this.onRetry, required this.height});

  final VoidCallback onRetry;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      height: height,
      padding: const EdgeInsets.all(Spacing.x4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.cloud_off_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: Spacing.x3),
          Expanded(
            child: Text(
              l10n.dashboardCardFailed,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
        ],
      ),
    );
  }
}
