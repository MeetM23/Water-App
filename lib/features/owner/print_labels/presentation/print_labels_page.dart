import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../domain/models/product.dart';
import '../../labels/data/label_pdf_builder.dart';
import '../../labels/domain/label_sheet_spec.dart';
import '../../products/application/product_list_controller.dart';
import '../application/label_generation_service.dart';

/// Local format option definition for UI selection.
class _FormatOption {
  const _FormatOption({
    required this.id,
    required this.title,
    required this.sub1,
    required this.sub2,
    required this.icon,
  });

  final String id;
  final String title;
  final String sub1;
  final String sub2;
  final IconData icon;
}

const List<_FormatOption> _kFormatOptions = <_FormatOption>[
  _FormatOption(
    id: 'a4_24',
    title: 'A4 Sheet',
    sub1: '24 labels',
    sub2: '70 × 37 mm',
    icon: Icons.grid_view_rounded,
  ),
  _FormatOption(
    id: 'a4_65',
    title: 'A4 Sheet',
    sub1: '65 labels',
    sub2: '38.1 × 21.2 mm',
    icon: Icons.apps_rounded,
  ),
  _FormatOption(
    id: 'thermal',
    title: 'Thermal Label',
    sub1: '50 × 25 mm',
    sub2: 'Continuous roll',
    icon: Icons.label_outlined,
  ),
];

/// The new Admin Print Labels page powered by real product data and PDF compilation.
class PrintLabelsPage extends ConsumerStatefulWidget {
  /// Creates the page.
  const PrintLabelsPage({super.key});

  @override
  ConsumerState<PrintLabelsPage> createState() => _PrintLabelsPageState();
}

class _PrintLabelsPageState extends ConsumerState<PrintLabelsPage> {
  String _selectedFormatId = 'thermal';
  final Set<String> _selectedProductIds = <String>{};
  final Map<String, int> _productQuantities = <String, int>{};

  bool _isGenerating = false;
  List<LabelJobItem>? _cachedJobItems;

  LabelSheetSpec get _selectedSpec {
    return switch (_selectedFormatId) {
      'a4_24' => LabelSheets.a4TwentyFourUp,
      'a4_65' => LabelSheets.a4SixtyFiveUp,
      _ => LabelSheets.thermalFiftyByTwentyFive,
    };
  }

  void _clearCache() {
    _cachedJobItems = null;
  }

  void _toggleProduct(Product product) {
    final id = product.id;
    if (_isGenerating) return;
    setState(() {
      _clearCache();
      if (_selectedProductIds.contains(id)) {
        _selectedProductIds.remove(id);
        _productQuantities.remove(id);
      } else {
        _selectedProductIds.add(id);
        _productQuantities[id] = product.availableStock > 0 ? product.availableStock : 1;
      }
    });
  }

  void _updateQuantity(String id, int delta) {
    if (_isGenerating) return;
    setState(() {
      _clearCache();
      final current = _productQuantities[id] ?? 1;
      final updated = (current + delta).clamp(1, 100);
      _productQuantities[id] = updated;
    });
  }

  Future<void> _onDownloadPressed(List<Product> availableProducts) async {
    if (_isGenerating || _selectedProductIds.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    final selectedProducts = availableProducts
        .where((p) => _selectedProductIds.contains(p.id))
        .toList();

    try {
      final result = await ref
          .read(labelGenerationServiceProvider)
          .generateLabelsPdf(
            selectedProducts: selectedProducts,
            quantities: _productQuantities,
            spec: _selectedSpec,
            existingJobItems: _cachedJobItems,
          );

      if (!mounted) return;

      result.fold(
        onSuccess: (data) async {
          _cachedJobItems = data.jobItems;
          await Printing.layoutPdf(
            onLayout: (format) async => data.pdfBytes,
            name: 'Labels_${DateTime.now().millisecondsSinceEpoch}',
          );
        },
        onFailure: (failure) {
          AppSnackbar.error(
            context,
            failure.title(context.l10n),
          );
        },
      );
    } catch (error) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Unable to generate labels. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listState = ref.watch(productListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.actionPrintLabels),
      ),
      body: SafeArea(
        child: listState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => AppErrorState(
            failure: error is AppFailure
                ? error
                : UnexpectedFailure(cause: error, stackTrace: stackTrace),
            onRetry: () =>
                ref.read(productListControllerProvider.notifier).refresh(),
          ),
          data: (ProductListState state) {
            if (state.products.isEmpty) {
              return AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: l10n.productsEmptyTitle,
                message: l10n.productsEmptyBody,
              );
            }
            return _buildContent(context, state.products);
          },
        ),
      ),
      bottomNavigationBar: listState.maybeWhen(
        data: (ProductListState state) => _buildBottomBar(state.products),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Product> products) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.x4,
        vertical: Spacing.x3,
      ),
      children: <Widget>[
        _buildSectionHeader(context, 'LABEL FORMAT'),
        const SizedBox(height: Spacing.x2),
        _buildFormatOptions(),
        const SizedBox(height: Spacing.x6),
        _buildSectionHeader(context, 'SELECT PRODUCTS'),
        const SizedBox(height: Spacing.x2),
        _buildProductList(products),
        const SizedBox(height: Spacing.x8),
      ],
    );
  }

  Widget _buildBottomBar(List<Product> products) {
    final hasSelection = _selectedProductIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(Spacing.x4),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: AppButton(
          label: _isGenerating ? 'GENERATING LABELS...' : 'DOWNLOAD LABELS',
          icon: Icons.download_rounded,
          isLoading: _isGenerating,
          onPressed: (!hasSelection || _isGenerating)
              ? null
              : () => _onDownloadPressed(products),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: context.textTheme.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildFormatOptions() {
    return Column(
      children: _kFormatOptions.map((option) {
        final isSelected = option.id == _selectedFormatId;
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.x2),
          child: AppCard(
            isSelected: isSelected,
            onTap: _isGenerating
                ? null
                : () => setState(() {
                      _clearCache();
                      _selectedFormatId = option.id;
                    }),
            child: Row(
              children: <Widget>[
                Radio<String>(
                  value: option.id,
                  groupValue: _selectedFormatId,
                  onChanged: _isGenerating
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() {
                              _clearCache();
                              _selectedFormatId = val;
                            });
                          }
                        },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: Spacing.x2),
                Icon(
                  option.icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: Spacing.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        option.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: Spacing.x1),
                      Text(
                        '${option.sub1} • ${option.sub2}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return Column(
      children: products.map((product) {
        final isSelected = _selectedProductIds.contains(product.id);
        final quantity = _productQuantities[product.id] ?? (product.availableStock > 0 ? product.availableStock : 1);

        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.x3),
          child: AppCard(
            isSelected: isSelected,
            onTap: _isGenerating ? null : () => _toggleProduct(product),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: isSelected,
                      onChanged: _isGenerating
                          ? null
                          : (_) => _toggleProduct(product),
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: Spacing.x2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: product.availableStock > 0
                                      ? AppColors.primaryTint
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Stock: ${product.availableStock} pcs',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: product.availableStock > 0
                                        ? AppColors.primaryDark
                                        : AppColors.danger,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.x1),
                          Text(
                            product.productCode,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isSelected) ...<Widget>[
                  const Divider(height: Spacing.x5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Labels to print',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          _IconButtonCircle(
                            icon: Icons.remove_rounded,
                            onPressed: (!_isGenerating && quantity > 1)
                                ? () => _updateQuantity(product.id, -1)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.x4,
                            ),
                            child: SizedBox(
                              width: 32,
                              child: Text(
                                '$quantity',
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          _IconButtonCircle(
                            icon: Icons.add_rounded,
                            onPressed: (!_isGenerating && quantity < 100)
                                ? () => _updateQuantity(product.id, 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IconButtonCircle extends StatelessWidget {
  const _IconButtonCircle({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Material(
      color: isEnabled ? AppColors.primaryTint : AppColors.disabledFill,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.x2),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? AppColors.primary : AppColors.disabledInk,
          ),
        ),
      ),
    );
  }
}
