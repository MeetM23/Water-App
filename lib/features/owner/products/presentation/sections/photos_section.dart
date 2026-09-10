import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../core/utils/media_permissions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../domain/models/product_draft.dart';
import '../../application/product_detail_controller.dart';
import '../../application/product_form_controller.dart';

/// The photo grid on the product form.
///
/// Images upload as soon as they are chosen so the owner is not left waiting
/// at save time, and each tile carries its own progress and failure state.
class PhotosSection extends ConsumerWidget {
  /// Creates the photos section.
  const PhotosSection({
    required this.productId,
    required this.draft,
    super.key,
  });

  /// Which form instance this belongs to.
  final String? productId;

  /// The draft being edited.
  final ProductDraft draft;

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    MediaSource source,
  ) async {
    final l10n = context.l10n;

    final permission = await MediaPermissions.request(source);
    if (!context.mounted) {
      return;
    }

    if (permission == MediaPermissionResult.permanentlyDenied) {
      await _showPermanentlyDenied(context);
      return;
    }
    if (permission == MediaPermissionResult.denied) {
      AppSnackbar.error(context, l10n.permissionCameraTitle);
      return;
    }

    try {
      final picked = await ImagePicker().pickImage(
        source: source == MediaSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        // The compressor does the real work; this only avoids handing it a
        // 50 megapixel original from a modern phone camera.
        maxWidth: 3000,
        maxHeight: 3000,
      );
      if (picked == null) {
        return;
      }
      await ref
          .read(productFormControllerProvider(productId).notifier)
          .addImage(File(picked.path));
    } on Object catch (error, stackTrace) {
      AppLog.warn('Image selection failed', error, stackTrace);
      if (context.mounted) {
        AppSnackbar.error(context, l10n.errorGenericTitle);
      }
    }
  }

  Future<void> _showPermanentlyDenied(BuildContext context) async {
    final l10n = context.l10n;
    final opened = await AppConfirmDialog.show(
      context,
      title: l10n.permissionCameraTitle,
      message: l10n.permissionCameraBody,
      confirmLabel: l10n.permissionOpenSettings,
    );
    if (!opened) {
      return;
    }
    final launched = await MediaPermissions.openSettings();
    if (!launched && context.mounted) {
      AppSnackbar.error(context, l10n.permissionSettingsFailed);
    }
  }

  Future<void> _showSourceChooser(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    if (draft.images.length >= maxProductImages) {
      AppSnackbar.show(context, l10n.photosLimitReached(maxProductImages));
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(Spacing.x5),
              child: Text(
                l10n.chooseSourceTitle,
                style: sheetContext.textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.sourceCamera),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(context, ref, MediaSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.sourceGallery),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(context, ref, MediaSource.gallery);
              },
            ),
            const SizedBox(height: Spacing.x3),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    DraftImage image,
  ) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.photosRemoveTitle,
      message: l10n.photosRemoveBody,
      confirmLabel: l10n.actionRemove,
      isDestructive: true,
    );
    if (confirmed) {
      await ref
          .read(productFormControllerProvider(productId).notifier)
          .removeImage(image.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(
      productFormControllerProvider(productId).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (draft.images.isEmpty)
          AppButton(
            label: l10n.photosAdd,
            onPressed: () => _showSourceChooser(context, ref),
            icon: Icons.add_a_photo_outlined,
            variant: AppButtonVariant.secondary,
          )
        else
          SizedBox(
            height: 116,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: false,
                    itemCount: draft.images.length,
                    onReorder: controller.reorderImages,
                    itemBuilder: (BuildContext context, int index) {
                      final image = draft.images[index];
                      return ReorderableDragStartListener(
                        key: ValueKey<String>(image.id),
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(right: Spacing.x3),
                          child: _PhotoTile(
                            image: image,
                            onSetPrimary: () =>
                                controller.setPrimaryImage(image.id),
                            onRemove: () => _confirmRemove(context, ref, image),
                            onRetry: () => controller.retryImage(image.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (draft.images.length < maxProductImages)
                  _AddTile(onTap: () => _showSourceChooser(context, ref)),
              ],
            ),
          ),
        const SizedBox(height: Spacing.x3),
        Text(
          l10n.photosHelp(maxProductImages),
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (draft.images.length > 1) ...<Widget>[
          const SizedBox(height: Spacing.x1),
          Text(
            l10n.photosReorderHint,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardAll,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
      ),
    );
  }
}

class _PhotoTile extends ConsumerWidget {
  const _PhotoTile({
    required this.image,
    required this.onSetPrimary,
    required this.onRemove,
    required this.onRetry,
  });

  final DraftImage image;
  final VoidCallback onSetPrimary;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return SizedBox(
      height: 100,
      width: 100,
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _preview(ref),
            if (image.isUploading)
              ColoredBox(
                color: AppColors.ink.withOpacity(0.45),
                child: Center(
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      value: image.uploadProgress > 0
                          ? image.uploadProgress
                          : null,
                      strokeWidth: 2.5,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
            if (image.failureMessage != null)
              Tooltip(
                message: l10n.photosUploadFailed,
                child: InkWell(
                  onTap: onRetry,
                  child: ColoredBox(
                    color: AppColors.danger.withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.x2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.surface,
                          ),
                          const SizedBox(height: Spacing.x1),
                          Text(
                            l10n.actionRetry,
                            textAlign: TextAlign.center,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppColors.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (image.isPrimary)
              Positioned(
                left: Spacing.x1,
                top: Spacing.x1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.x2,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Text(
                    l10n.photosPrimary,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.surface,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.surface,
                  size: 18,
                ),
                onSelected: (String value) =>
                    value == 'primary' ? onSetPrimary() : onRemove(),
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  if (!image.isPrimary)
                    PopupMenuItem<String>(
                      value: 'primary',
                      child: Text(l10n.photosSetPrimary),
                    ),
                  PopupMenuItem<String>(
                    value: 'remove',
                    child: Text(l10n.actionRemove),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview(WidgetRef ref) {
    if (image.localPath != null) {
      return Image.file(File(image.localPath!), fit: BoxFit.cover);
    }
    if (image.storagePath.isEmpty) {
      return const ColoredBox(color: AppColors.skeletonBase);
    }

    final url = ref.watch(signedImageUrlProvider(image.storagePath));
    return url.when(
      data: (String? value) => value == null
          ? const ColoredBox(color: AppColors.skeletonBase)
          : CachedNetworkImage(imageUrl: value, fit: BoxFit.cover),
      loading: () => const ColoredBox(color: AppColors.skeletonBase),
      error: (_, __) => const ColoredBox(color: AppColors.skeletonBase),
    );
  }
}
