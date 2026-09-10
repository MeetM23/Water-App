import 'package:flutter/material.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../widgets/gallery_section.dart';

/// Empty, error, loading and feedback states.
class StatesSection extends StatelessWidget {
  /// Creates the states section.
  const StatesSection({super.key});

  static const List<AppFailure> _failures = <AppFailure>[
    NetworkFailure(),
    ServerFailure(),
    AuthFailure(AuthFailureReason.sessionExpired),
    UnexpectedFailure(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GallerySection(
          title: 'Empty states',
          children: <Widget>[
            GallerySpecimen(
              caption: 'with primary action',
              child: _Frame(
                child: AppEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: l10n.emptyDefaultTitle,
                  message: l10n.emptyDefaultBody,
                  actionLabel: l10n.actionRefresh,
                  onAction: () {},
                ),
              ),
            ),
            GallerySpecimen(
              caption: 'without action',
              child: _Frame(
                child: AppEmptyState(
                  icon: Icons.search_off_rounded,
                  title: l10n.emptyDefaultTitle,
                  message: l10n.emptyDefaultBody,
                ),
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'Error states',
          children: <Widget>[
            for (final AppFailure failure in _failures)
              GallerySpecimen(
                caption: failure.runtimeType.toString(),
                child: _Frame(
                  child: AppErrorState(failure: failure, onRetry: () {}),
                ),
              ),
          ],
        ),
        const GallerySection(
          title: 'Skeletons',
          children: <Widget>[
            GallerySpecimen(
              caption: 'list row placeholder, shimmering',
              child: AppShimmer(child: _SkeletonRows()),
            ),
          ],
        ),
        GallerySection(
          title: 'Dialogs and snackbars',
          children: <Widget>[
            GallerySpecimen(
              caption: 'destructive confirmation',
              child: AppButton(
                label: 'Show confirm dialog',
                variant: AppButtonVariant.danger,
                onPressed: () => AppConfirmDialog.show(
                  context,
                  title: 'Delete product?',
                  message:
                      'Aqua Grand Domestic RO Purifier will be removed from '
                      'the catalogue. This cannot be undone.',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                ),
              ),
            ),
            GallerySpecimen(
              caption: 'snackbars',
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton(
                      label: 'Success',
                      variant: AppButtonVariant.secondary,
                      onPressed: () =>
                          AppSnackbar.success(context, 'Product saved'),
                    ),
                  ),
                  const SizedBox(width: Spacing.x2),
                  Expanded(
                    child: AppButton(
                      label: 'Error',
                      variant: AppButtonVariant.secondary,
                      onPressed: () =>
                          AppSnackbar.error(context, l10n.errorNetworkTitle),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        borderRadius: AppRadius.cardAll,
        border: AppShadows.hairline,
      ),
      child: child,
    );
  }
}

class _SkeletonRows extends StatelessWidget {
  const _SkeletonRows();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int index = 0; index < 3; index++)
          const Padding(
            padding: EdgeInsets.only(bottom: Spacing.x3),
            child: AppCard(
              child: Row(
                children: <Widget>[
                  AppSkeleton(width: 56, height: 56),
                  SizedBox(width: Spacing.x4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AppSkeleton(width: 180),
                        SizedBox(height: Spacing.x2),
                        AppSkeleton(width: 120, height: 10),
                        SizedBox(height: Spacing.x2),
                        AppSkeleton(width: 80, height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
