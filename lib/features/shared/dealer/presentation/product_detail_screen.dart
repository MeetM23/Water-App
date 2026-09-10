import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/product_code.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../domain/models/business_settings.dart';
import '../../../../domain/models/catalog_product.dart';
import '../../../auth/application/session_controller.dart';
import '../../../owner/settings/application/business_settings_controller.dart';
import '../application/product_lookup_controller.dart';
import '../application/product_share.dart';
import '../application/saved_controller.dart';
import '../domain/dealer_experience.dart';
import 'category_label.dart';
import 'widgets/catalogue_image.dart';
import 'widgets/product_gallery.dart';

/// Everything a dealer needs to quote one product.
///
/// Keyed by the printed code rather than by the row id, because the two ways
/// in are a scanned label and a code read out over the phone, and neither of
/// them knows a uuid.
///
/// There is one price on this screen. `catalog_view` resolved which one from
/// the caller's role inside the database, so there is no second figure here to
/// hide, dim or accidentally show — and [experience] names the figure without
/// choosing it.
///
/// Prefixed because the owner build already has a `ProductDetailScreen` and
/// the router imports both files into the same library.
class DealerProductDetailScreen extends ConsumerWidget {
  /// Creates the detail screen for [productCode].
  const DealerProductDetailScreen({
    required this.productCode,
    required this.experience,
    super.key,
  });

  /// The code printed under the barcode on the label.
  final String productCode;

  /// What separates this role's product screen from the other's.
  final DealerExperience experience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(productByCodeProvider(productCode));
    final product = detail.valueOrNull;

    final uri = GoRouterState.of(context).uri;
    final autoEnquire = uri.queryParameters['autoEnquire'] == 'true';
    if (autoEnquire && product != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final session = ref.read(sessionControllerProvider).valueOrNull;
        if (session is SessionSignedIn && session.profile.isApproved) {
          _ActionBar.launchEnquire(context, product);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.productDetailTitle)),
      body: detail.when(
        loading: () => const _DetailSkeleton(),
        error: (Object error, StackTrace stackTrace) => AppErrorState(
          failure: error is AppFailure
              ? error
              : UnexpectedFailure(cause: error, stackTrace: stackTrace),
          onRetry: () => ref.invalidate(productByCodeProvider(productCode)),
        ),
        data: (CatalogProduct? value) => value == null
            ? _NoMatch(productCode: productCode, experience: experience)
            : _Body(product: value, priceLabel: experience.priceLabel(l10n)),
      ),
      // Pinned rather than scrolled to: save, share and enquire are why the
      // dealer opened this, and none of them should need a scroll to reach.
      bottomNavigationBar: product == null
          ? null
          : _ActionBar(product: product),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.product, required this.priceLabel});

  final CatalogProduct product;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    final description = product.description?.trim() ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.x4,
        Spacing.x4,
        Spacing.x4,
        Spacing.x8,
      ),
      children: <Widget>[
        ProductGallery(product: product),
        const SizedBox(height: Spacing.x5),
        _Header(product: product),
        const SizedBox(height: Spacing.x5),
        _PriceCard(product: product, priceLabel: priceLabel),
        const SizedBox(height: Spacing.x5),
        _SpecificationsCard(product: product),
        if (description.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.x5),
          _DescriptionCard(description: description),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final model = product.modelNumber?.trim() ?? '';
    final capacity = product.capacity?.trim() ?? '';
    final warrantyMonths = product.warrantyMonths;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          product.name,
          style: context.textTheme.headlineMedium?.copyWith(
            color: AppColors.ink,
          ),
        ),
        if (model.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.x1),
          Text(
            model,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: Spacing.x2),
        Text(
          product.productCode,
          style: AppTypography.mono.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Spacing.x4),
        Wrap(
          spacing: Spacing.x2,
          runSpacing: Spacing.x2,
          children: <Widget>[
            AppBadge(
              label: product.category.catalogueLabel(l10n),
              tone: AppBadgeTone.info,
            ),
            AppBadge(
              label: product.inStock ? l10n.badgeInStock : l10n.badgeOutOfStock,
              // Red rather than amber when it is out. This is the one fact on
              // the screen that changes what the dealer can promise today, and
              // a caution colour reads as a footnote next to the price.
              tone: product.inStock
                  ? AppBadgeTone.success
                  : AppBadgeTone.danger,
            ),
            if (capacity.isNotEmpty)
              AppBadge(label: capacity, icon: Icons.water_drop_outlined),
            if (warrantyMonths != null)
              AppBadge(
                label: l10n.productWarranty(warrantyMonths),
                icon: Icons.verified_outlined,
              ),
          ],
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.product, required this.priceLabel});

  final CatalogProduct product;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Spacing.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            priceLabel,
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.x2),
          // Scaled down rather than wrapped or ellipsised: a lakh figure at a
          // 2.0 text scale is wider than a 320dp screen, and half a price is
          // worse than a slightly smaller one.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppFormat.rupees(product.price),
              maxLines: 1,
              style: context.textTheme.headlineLarge?.copyWith(
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecificationsCard extends StatelessWidget {
  const _SpecificationsCard({required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final capacity = product.capacity?.trim() ?? '';
    // Capacity is a column of its own on the product record rather than a
    // jsonb key, but a dealer reading a spec sheet does not care where a fact
    // was stored, so it joins the table at the top.
    final rows = <MapEntry<String, String>>[
      if (capacity.isNotEmpty)
        MapEntry<String, String>(l10n.fieldCapacity, capacity),
      ...product.specificationRows,
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.productSpecifications,
            style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: Spacing.x3),
          if (rows.isEmpty)
            Text(
              l10n.productNoSpecifications,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          for (var index = 0; index < rows.length; index++) ...<Widget>[
            if (index > 0)
              const Divider(height: Spacing.x5, color: AppColors.border),
            _SpecificationRow(label: rows[index].key, value: rows[index].value),
          ],
        ],
      ),
    );
  }
}

class _SpecificationRow extends StatelessWidget {
  const _SpecificationRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    );
    final valueStyle = context.textTheme.bodyMedium?.copyWith(
      color: AppColors.ink,
    );

    // Two columns stop working somewhere past a 1.4x text scale on a 320dp
    // phone: the value column ends up narrower than a single unbreakable word
    // such as a membrane rating, which then paints outside the card. Beyond
    // that the row stacks, which costs a line and cannot overflow.
    final isStacked = MediaQuery.textScalerOf(context).scale(14) > 20;

    if (isStacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: labelStyle),
          const SizedBox(height: Spacing.x1),
          Text(value, style: valueStyle),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(flex: 2, child: Text(label, style: labelStyle)),
        const SizedBox(width: Spacing.x3),
        Expanded(flex: 3, child: Text(value, style: valueStyle)),
      ],
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.productDescription,
            style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: Spacing.x3),
          Text(
            description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Save, share and enquire, pinned to the bottom of the screen.
class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.product});

  final CatalogProduct product;

  Future<void> _toggleSave(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final isSaved = await ref
        .read(savedControllerProvider.notifier)
        .toggle(product.productCode);

    if (!context.mounted) {
      return;
    }
    AppSnackbar.success(
      context,
      isSaved
          ? l10n.productSavedToast(product.name)
          : l10n.productUnsavedToast(product.name),
    );
  }

  Future<void> _share(
    BuildContext context,
    WidgetRef ref,
    BusinessSettings business,
  ) async {
    final l10n = context.l10n;
    final message = buildShareMessage(
      product: product,
      business: business,
      l10n: l10n,
    );
    final photo = _warmPrimaryImage(ref);

    try {
      if (photo == null) {
        await Share.share(message, subject: product.name);
      } else {
        await Share.shareXFiles(
          <XFile>[photo],
          text: message,
          subject: product.name,
        );
      }
    } on Object catch (error, stackTrace) {
      AppLog.error('Sharing a product failed', error, stackTrace);
      if (context.mounted) {
        AppSnackbar.error(context, l10n.productShareFailed);
      }
    }
  }

  static Future<void> launchEnquire(
    BuildContext context,
    CatalogProduct product,
  ) async {
    final l10n = context.l10n;
    final launched = await ContactLauncher.openWhatsApp(
      prefilledMessage: buildEnquiryMessage(product: product, l10n: l10n),
    );

    if (!launched && context.mounted) {
      AppSnackbar.error(context, l10n.contactUnavailable);
    }
  }

  Future<void> _enquire(BuildContext context, WidgetRef ref) async {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    final isAuthed = session is SessionSignedIn && session.profile.isApproved;

    if (!isAuthed) {
      final currentUri = GoRouterState.of(context).uri;
      final rawPath = currentUri
          .toString()
          .replaceAll('&autoEnquire=true', '')
          .replaceAll('?autoEnquire=true', '');
      final separator = rawPath.contains('?') ? '&' : '?';
      final returnUrl = Uri.encodeComponent('$rawPath${separator}autoEnquire=true');
      context.push('${AppRoutes.login}?from=$returnUrl');
      return;
    }

    await launchEnquire(context, product);
  }

  /// The primary photo, but only when it is already decoded in memory.
  ///
  /// Never waits on a download. The dealer taps share with a customer in front
  /// of them, and a message that goes now beats a photo that arrives after a
  /// 2G round trip; the gallery above has almost always warmed this already,
  /// and when it has not the message simply travels as text.
  XFile? _warmPrimaryImage(WidgetRef ref) {
    final path = product.primaryImagePath;
    if (path == null) {
      return null;
    }

    final bytes = ref.read(catalogueImageBytesProvider(path)).valueOrNull;
    if (bytes == null) {
      return null;
    }

    // Uploads are normalised to JPEG on the way into storage, so the type is
    // known without sniffing the bytes.
    return XFile.fromData(bytes, name: _shareFileName, mimeType: 'image/jpeg');
  }

  /// What the attached photo is called in the customer's chat.
  String get _shareFileName => '${product.productCode}.jpg';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isSaved = ref
        .watch(savedControllerProvider)
        .contains(product.productCode);
    // Watched while the screen is open rather than read at the moment of the
    // tap. The record is kept alive but starts empty in a dealer session, so a
    // share fired before it lands would go out without the phone number the
    // customer is supposed to ring - which is most of the point of sharing.
    final business =
        ref.watch(businessSettingsControllerProvider).valueOrNull ??
        fallbackShareBusiness;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.x3),
          // Two icons and one labelled button, rather than three labels: at a
          // 2.0 text scale on a 320dp screen three labels cannot share a row,
          // and enquiring is the action worth spelling out.
          child: Row(
            children: <Widget>[
              _IconAction(
                icon: isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                tooltip: isSaved ? l10n.actionSaved : l10n.actionSave,
                onPressed: () => _toggleSave(context, ref),
                isActive: isSaved,
              ),
              const SizedBox(width: Spacing.x2),
              _IconAction(
                icon: Icons.share_outlined,
                tooltip: l10n.actionShare,
                onPressed: () => _share(context, ref, business),
              ),
              const SizedBox(width: Spacing.x3),
              Expanded(
                child: AppButton(
                  label: l10n.actionEnquire,
                  onPressed: () => _enquire(context, ref),
                  icon: Icons.chat_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        foregroundColor: isActive ? AppColors.primary : AppColors.textSecondary,
        backgroundColor: isActive
            ? AppColors.primaryTint
            : AppColors.disabledFill,
        minimumSize: const Size.square(48),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.controlAll),
      ),
    );
  }
}

/// What the screen shows when the code resolves to nothing.
class _NoMatch extends StatelessWidget {
  const _NoMatch({required this.productCode, required this.experience});

  final String productCode;
  final DealerExperience experience;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(Spacing.x4),
      children: <Widget>[
        ConstrainedBox(
          // A minimum, not a fixed height: at a large system text scale the
          // empty state is taller than this and must be free to grow into the
          // scroll view rather than overflow a box that cannot hold it.
          constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height * 0.5,
          ),
          child: AppEmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.catalogueNoResultsTitle,
            // A code that fails the check character is somebody else's
            // barcode, which is a different problem from one of ours that
            // matches nothing, and the dealer can act on the difference.
            message: ProductCode.isValid(productCode)
                ? l10n.scanUnknownCode
                : l10n.scanInvalidCode,
            actionLabel: l10n.navCatalogue,
            onAction: () => context.go(experience.catalogueRoute),
          ),
        ),
        // Printed back so the dealer can check it against the label in their
        // hand, or read it out to whoever sent it.
        Center(
          child: Text(
            productCode,
            style: AppTypography.mono.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      // A scroll view rather than a bare column: these blocks add up to more
      // than a 320x568 phone can show, and a placeholder that overflows puts
      // a striped bar across the first thing the dealer sees. It does not
      // scroll - the real screen arrives at the top and that is where the eye
      // should be.
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.x4),
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSkeleton(height: 200, borderRadius: AppRadius.cardAll),
            SizedBox(height: Spacing.x5),
            AppSkeleton(width: 220, height: 22),
            SizedBox(height: Spacing.x3),
            AppSkeleton(width: 140, height: 12),
            SizedBox(height: Spacing.x6),
            AppSkeleton(height: 96, borderRadius: AppRadius.cardAll),
            SizedBox(height: Spacing.x5),
            AppSkeleton(height: 180, borderRadius: AppRadius.cardAll),
          ],
        ),
      ),
    );
  }
}
