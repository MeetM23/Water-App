import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../domain/models/dashboard_banner.dart';
import '../../../shared/banner/application/banner_controller.dart';
import '../../../shared/banner/presentation/widgets/banner_image.dart';

/// Admin screen for managing home dashboard promotional carousel banners.
class ManageBannersScreen extends ConsumerStatefulWidget {
  /// Creates the banner management screen.
  const ManageBannersScreen({super.key});

  @override
  ConsumerState<ManageBannersScreen> createState() => _ManageBannersScreenState();
}

class _ManageBannersScreenState extends ConsumerState<ManageBannersScreen> {
  bool _isProcessing = false;

  Future<void> _addBanner() async {
    final l10n = context.l10n;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 3000,
        maxHeight: 3000,
      );
      if (picked == null) return;

      setState(() {
        _isProcessing = true;
      });

      final appDir = await getApplicationDocumentsDirectory();
      final bannerDir = Directory('${appDir.path}/banners');
      if (!await bannerDir.exists()) {
        await bannerDir.create(recursive: true);
      }
      final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(picked.path).copy('${bannerDir.path}/$fileName');

      await ref
          .read(adminBannersControllerProvider.notifier)
          .addBanner(imageFile: savedFile);

      if (mounted) {
        AppSnackbar.show(context, l10n.bannerUploadSuccess);
      }
    } catch (error, stackTrace) {
      AppLog.error('Failed to add banner', error, stackTrace);
      if (mounted) {
        AppSnackbar.error(context, l10n.errorGenericTitle);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _replaceImage(DashboardBanner banner) async {
    final l10n = context.l10n;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 3000,
        maxHeight: 3000,
      );
      if (picked == null) return;

      setState(() {
        _isProcessing = true;
      });

      final appDir = await getApplicationDocumentsDirectory();
      final bannerDir = Directory('${appDir.path}/banners');
      if (!await bannerDir.exists()) {
        await bannerDir.create(recursive: true);
      }
      final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(picked.path).copy('${bannerDir.path}/$fileName');

      await ref
          .read(adminBannersControllerProvider.notifier)
          .replaceImage(
            bannerId: banner.id,
            oldStoragePath: banner.storagePath,
            newImageFile: savedFile,
          );

      if (mounted) {
        AppSnackbar.show(context, l10n.bannerUploadSuccess);
      }
    } catch (error, stackTrace) {
      AppLog.error('Failed to replace banner image', error, stackTrace);
      if (mounted) {
        AppSnackbar.error(context, l10n.errorGenericTitle);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(DashboardBanner banner) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.bannerDeleteConfirmTitle,
      message: l10n.bannerDeleteConfirmBody,
      confirmLabel: l10n.bannerActionDelete,
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await ref
          .read(adminBannersControllerProvider.notifier)
          .deleteBanner(
            bannerId: banner.id,
            storagePath: banner.storagePath,
          );

      if (mounted) {
        AppSnackbar.show(context, l10n.bannerDeleteSuccess);
      }
    } catch (error, stackTrace) {
      AppLog.error('Failed to delete banner', error, stackTrace);
      if (mounted) {
        AppSnackbar.error(context, l10n.errorGenericTitle);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(adminBannersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageBannersTitle),
      ),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => AppErrorState(
            failure: error is AppFailure
                ? error
                : UnexpectedFailure(cause: error, stackTrace: stackTrace),
            onRetry: () =>
                ref.read(adminBannersControllerProvider.notifier).refresh(),
          ),
          data: (List<DashboardBanner> banners) {
            if (banners.isEmpty) {
              return AppEmptyState(
                icon: Icons.view_carousel_outlined,
                title: l10n.bannerEmptyTitle,
                message: l10n.bannerEmptyBody,
                actionLabel: l10n.actionAddBanner,
                onAction: _isProcessing ? null : _addBanner,
              );
            }

            return ListView(
              padding: const EdgeInsets.all(Spacing.x4),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.x3),
                  child: Text(
                    l10n.bannerRecommendedHint,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ...List.generate(banners.length, (int index) {
                  final banner = banners[index];
                  return _BannerCard(
                    banner: banner,
                    position: index + 1,
                    isFirst: index == 0,
                    isLast: index == banners.length - 1,
                    isProcessing: _isProcessing,
                    onMoveUp: () => ref
                        .read(adminBannersControllerProvider.notifier)
                        .moveBanner(banner.id, -1),
                    onMoveDown: () => ref
                        .read(adminBannersControllerProvider.notifier)
                        .moveBanner(banner.id, 1),
                    onToggleActive: (bool val) => ref
                        .read(adminBannersControllerProvider.notifier)
                        .toggleStatus(banner.id, val),
                    onReplace: () => _replaceImage(banner),
                    onDelete: () => _confirmDelete(banner),
                  );
                }),
                const SizedBox(height: Spacing.x8),
              ],
            );
          },
        ),
      ),
      floatingActionButton: state.maybeWhen(
        data: (banners) => banners.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _isProcessing ? null : _addBanner,
                icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
                label: Text(
                  l10n.actionAddBanner,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.banner,
    required this.position,
    required this.isFirst,
    required this.isLast,
    required this.isProcessing,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onToggleActive,
    required this.onReplace,
    required this.onDelete,
  });

  final DashboardBanner banner;
  final int position;
  final bool isFirst;
  final bool isLast;
  final bool isProcessing;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x4),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 7,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildBannerPreview(banner),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.x4),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      AppBadge(
                        label: 'Pos #$position',
                        tone: AppBadgeTone.neutral,
                      ),
                      const SizedBox(width: Spacing.x2),
                      AppBadge(
                        label: banner.isActive
                            ? l10n.bannerStatusActive
                            : l10n.bannerStatusInactive,
                        tone: banner.isActive
                            ? AppBadgeTone.success
                            : AppBadgeTone.warning,
                      ),
                      const Spacer(),
                      Switch(
                        value: banner.isActive,
                        onChanged: isProcessing ? null : onToggleActive,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const Divider(height: Spacing.x4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.arrow_upward_rounded),
                            tooltip: l10n.bannerActionMoveUp,
                            onPressed: (isProcessing || isFirst) ? null : onMoveUp,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_downward_rounded),
                            tooltip: l10n.bannerActionMoveDown,
                            onPressed: (isProcessing || isLast) ? null : onMoveDown,
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.image_outlined),
                            tooltip: l10n.bannerActionReplace,
                            onPressed: isProcessing ? null : onReplace,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.danger,
                            ),
                            tooltip: l10n.bannerActionDelete,
                            onPressed: isProcessing ? null : onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerPreview(DashboardBanner banner) {
    if (banner.storagePath.startsWith('test_banner_')) {
      final index = int.tryParse(banner.id.replaceAll('test_', '')) ?? 1;
      return _TestBannerCardItem(index: index - 1);
    }
    return BannerImage(
      storagePath: banner.storagePath,
      fit: BoxFit.cover,
    );
  }
}

class _TestBannerCardItem extends StatelessWidget {
  const _TestBannerCardItem({required this.index});

  final int index;

  static const List<List<Color>> _gradients = <List<Color>>[
    <Color>[Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
    <Color>[Color(0xFF11998E), Color(0xFF38EF7D)],
    <Color>[Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  ];

  static const List<String> _titles = <String>[
    'BANNER 1 — Special RO Deals',
    'BANNER 2 — Genuine Spare Parts',
    'BANNER 3 — Premium Water Filters',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[index % _gradients.length];
    final title = _titles[index % _titles.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.water_drop, color: Colors.white, size: 36),
            const SizedBox(height: Spacing.x2),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
