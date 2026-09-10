import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/errors/app_failure.dart';
import '../../../../../core/errors/failure_presentation.dart';
import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../domain/models/product.dart';
import '../../application/product_actions_controller.dart';

/// The long-press menu on a product row.
///
/// Everything here is reversible except delete, which is why delete is the only
/// entry that asks for confirmation and the only one drawn in the danger tone.
class ProductQuickActions extends ConsumerWidget {
  /// Creates the sheet.
  const ProductQuickActions({required this.product, super.key});

  /// The product being acted on.
  final Product product;

  /// Opens the sheet for [product].
  static Future<void> show(BuildContext context, {required Product product}) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => ProductQuickActions(product: product),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(productActionsControllerProvider.notifier);

    Future<void> run(Future<AppFailure?> Function() action) async {
      final screenContext = context;
      Navigator.of(context).pop();
      final failure = await action();
      if (failure != null && screenContext.mounted) {
        AppSnackbar.error(screenContext, failure.title(screenContext.l10n));
      }
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.x5,
              Spacing.x2,
              Spacing.x5,
              Spacing.x3,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              product.inStock
                  ? Icons.remove_shopping_cart_outlined
                  : Icons.add_shopping_cart_outlined,
            ),
            title: Text(l10n.quickToggleStock),
            subtitle: Text(
              product.inStock ? l10n.badgeInStock : l10n.badgeOutOfStock,
            ),
            onTap: () => run(() => controller.toggleStock(product)),
          ),
          ListTile(
            leading: Icon(
              product.isActive
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            title: Text(l10n.quickToggleActive),
            subtitle: Text(
              product.isActive ? l10n.statusActive : l10n.badgeInactive,
            ),
            onTap: () => run(() => controller.toggleActive(product)),
          ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: Text(l10n.quickDuplicate),
            onTap: () async {
              final navigator = Navigator.of(context);
              final screenContext = context;
              navigator.pop();
              final outcome = await controller.duplicate(product);
              if (!screenContext.mounted) {
                return;
              }
              if (outcome.failure != null) {
                AppSnackbar.error(
                  screenContext,
                  outcome.failure!.title(screenContext.l10n),
                );
              } else {
                AppSnackbar.success(
                  screenContext,
                  screenContext.l10n.productDuplicated(product.name),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppColors.ink),
            title: Text(l10n.actionEdit),
            onTap: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.ownerProductEdit(product.id));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
            title: Text(
              l10n.actionDelete,
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.danger,
              ),
            ),
            onTap: () async {
              final screenContext = context;
              final confirmed = await AppConfirmDialog.show(
                context,
                title: l10n.deleteProductTitle,
                message: l10n.deleteProductBody(product.name),
                confirmLabel: l10n.actionDelete,
                isDestructive: true,
              );
              if (!confirmed || !screenContext.mounted) {
                return;
              }
              Navigator.of(screenContext).pop();
              final failure = await controller.delete(product);
              if (!screenContext.mounted) {
                return;
              }
              if (failure != null) {
                AppSnackbar.error(
                  screenContext,
                  failure.title(screenContext.l10n),
                );
              } else {
                AppSnackbar.success(
                  screenContext,
                  screenContext.l10n.productDeleted(product.name),
                );
              }
            },
          ),
          const SizedBox(height: Spacing.x3),
        ],
      ),
    );
  }
}
