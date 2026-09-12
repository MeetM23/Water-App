import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../domain/models/catalog_product.dart';
import '../application/catalogue_controller.dart';
import '../application/quotation_controller.dart';
import '../application/saved_controller.dart';
import '../domain/dealer_experience.dart';
import 'widgets/catalogue_image.dart';

/// The dealer's shortlist, and the quotation it turns into.
///
/// This is where a visit ends: the dealer has saved a handful of products
/// while walking a customer through the catalogue, and now needs one sheet to
/// hand over. Everything here serves that, which is why the export button is
/// pinned to the bottom rather than hidden behind an app bar icon.
class SavedScreen extends ConsumerStatefulWidget {
  /// Creates the saved tab for one dealer role.
  const SavedScreen({required this.experience, super.key});

  /// What separates this role's shortlist from the other's: the word above each
  /// price, the route a row opens, and the wording of the exported quotation.
  final DealerExperience experience;

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _term = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered here rather than in a controller: a saved list is a dozen rows at
  // most, so a debounce and a provider rebuild would buy nothing and cost the
  // dealer a visible lag on every keystroke.
  void _search(String value) {
    setState(() {
      _term = value.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _search('');
  }

  Future<void> _refreshCatalogue() =>
      ref.read(catalogueControllerProvider.notifier).refresh();

  /// What the tab shows when the saved codes cannot be priced.
  ///
  /// A shortlist that will not resolve is a failure, not an empty list.
  /// Falling through to "nothing saved yet" would tell a dealer whose
  /// catalogue fetch died that their afternoon's work is gone, and they would
  /// start building it again from scratch.
  Widget _catalogueError(Object error, StackTrace stackTrace) => AppErrorState(
    failure: error is AppFailure
        ? error
        : UnexpectedFailure(cause: error, stackTrace: stackTrace),
    onRetry: _refreshCatalogue,
  );

  List<CatalogProduct> _matching(List<CatalogProduct> saved) {
    if (_term.isEmpty) {
      return saved;
    }
    return saved
        .where(
          (CatalogProduct product) =>
              product.name.toLowerCase().contains(_term) ||
              (product.modelNumber?.toLowerCase().contains(_term) ?? false) ||
              product.productCode.toLowerCase().contains(_term),
        )
        .toList();
  }

  /// Drops a product from the list without asking first.
  ///
  /// No confirmation: re-saving is one tap on the product screen, so a dialog
  /// here would guard against nothing and slow down the common case of tidying
  /// the list before quoting.
  Future<void> _remove(CatalogProduct product) async {
    final l10n = context.l10n;
    await ref
        .read(savedControllerProvider.notifier)
        .remove(product.productCode);

    if (mounted) {
      AppSnackbar.show(context, l10n.productUnsavedToast(product.name));
    }
  }

  /// Renders the quotation and hands it straight to the share sheet.
  ///
  /// Sharing rather than saving is deliberate: this file exists to be sent on
  /// WhatsApp within seconds, and a PDF dropped in Downloads is a file the
  /// dealer then has to go and find.
  Future<void> _export() async {
    final l10n = context.l10n;
    final bytes = await ref
        .read(quotationControllerProvider.notifier)
        .generate(widget.experience.quotation);

    if (!mounted) {
      return;
    }
    if (bytes == null) {
      AppSnackbar.error(context, l10n.savedExportFailed);
      return;
    }

    final fileName = QuotationController.fileNameFor(ref.read(nowProvider)());

    try {
      await Share.shareXFiles(
        <XFile>[
          XFile.fromData(bytes, name: fileName, mimeType: 'application/pdf'),
        ],
      );
    } on Object catch (error, stackTrace) {
      AppLog.error('Sharing the quotation failed', error, stackTrace);
      if (mounted) {
        AppSnackbar.error(context, l10n.savedExportFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final codes = ref.watch(savedControllerProvider);
    final saved = ref.watch(savedProductsProvider);
    final catalogue = ref.watch(catalogueControllerProvider);
    final isGenerating = ref.watch(quotationControllerProvider);

    // Saved codes only become products once the catalogue has resolved. Until
    // it has, an empty list means "still loading", not "nothing saved", and
    // the empty state would be telling the dealer their shortlist is gone.
    final isAwaitingCatalogue = saved.isEmpty && codes.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedTitle)),
      bottomNavigationBar: saved.isEmpty
          ? null
          : _ExportBar(isGenerating: isGenerating, onExport: _export),
      body: Column(
        children: <Widget>[
          if (saved.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.x4,
                Spacing.x3,
                Spacing.x4,
                Spacing.x2,
              ),
              child: AppSearchField(
                controller: _searchController,
                hint: l10n.savedSearchHint,
                clearTooltip: l10n.actionClear,
                onChanged: _search,
              ),
            ),
          Expanded(
            child: isAwaitingCatalogue
                ? catalogue.when(
                    loading: () => const _SavedSkeleton(),
                    error: _catalogueError,
                    data: (CatalogueState _) => _content(context, saved),
                  )
                : _content(context, saved),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, List<CatalogProduct> saved) {
    final l10n = context.l10n;
    final visible = _matching(saved);

    if (saved.isEmpty) {
      return AppEmptyState(
        icon: Icons.bookmark_border_rounded,
        title: l10n.savedEmptyTitle,
        message: l10n.savedEmptyBody,
      );
    }

    if (visible.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.catalogueNoResultsTitle,
        message: l10n.catalogueNoResultsBody,
        actionLabel: l10n.actionClear,
        onAction: _clearSearch,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        Spacing.x4,
        Spacing.x2,
        Spacing.x4,
        Spacing.x4,
      ),
      itemCount: visible.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          // The count describes the rows under it, so it counts what is on
          // screen: with a search running, the saved total would name a number
          // the dealer cannot see.
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.x1),
            child: Text(
              l10n.savedCount(visible.length),
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        final product = visible[index - 1];
        return _SavedRow(
          product: product,
          priceLabel: widget.experience.priceLabel(l10n),
          onOpen: () => context.push(
            widget.experience.productRoute(product.productCode),
          ),
          onRemove: () => _remove(product),
        );
      },
    );
  }
}

class _SavedRow extends StatelessWidget {
  const _SavedRow({
    required this.product,
    required this.priceLabel,
    required this.onOpen,
    required this.onRemove,
  });

  final CatalogProduct product;
  final String priceLabel;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final model = product.modelNumber?.trim() ?? '';

    return AppCard(
      padding: const EdgeInsets.all(Spacing.x3),
      onTap: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: AppRadius.controlAll,
            child: SizedBox(
              height: 72,
              width: 72,
              child: CatalogueImage(storagePath: product.primaryImagePath),
            ),
          ),
          const SizedBox(width: Spacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                if (model.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.x1),
                Text(
                  product.productCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.mono.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: Spacing.x2),
                // Shrunk rather than ellipsised: a rupee figure has no
                // line-break opportunity in it, so in this narrow column at a
                // large text scale it would otherwise be clipped mid-number.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    AppFormat.rupees(product.price),
                    maxLines: 1,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Stock is on the row because this list becomes a quotation:
                // a dealer who quotes something the client cannot ship has to
                // ring the customer back.
                if (!product.inStock) ...<Widget>[
                  const SizedBox(height: Spacing.x2),
                  AppBadge(
                    label: l10n.badgeOutOfStock,
                    tone: AppBadgeTone.warning,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.bookmark_remove_outlined),
            color: AppColors.textSecondary,
            tooltip: l10n.savedRemove,
          ),
        ],
      ),
    );
  }
}

class _ExportBar extends StatelessWidget {
  const _ExportBar({required this.isGenerating, required this.onExport});

  final bool isGenerating;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(Spacing.x4),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        // AppButton already refuses taps and paints a spinner while loading,
        // so the flag alone disables it.
        child: AppButton(
          label: context.l10n.savedExportPdf,
          onPressed: onExport,
          icon: Icons.picture_as_pdf_outlined,
          isLoading: isGenerating,
        ),
      ),
    );
  }
}

class _SavedSkeleton extends StatelessWidget {
  const _SavedSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(Spacing.x4),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
        itemBuilder: (_, __) => const AppSkeleton(height: 104),
      ),
    );
  }
}
