import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../data/repositories/supabase_unit_repository.dart';
import '../../../../domain/models/product_unit.dart';

/// Screen displaying product, machine, and warranty details for a scanned physical RO unit.
class UnitDetailScreen extends ConsumerWidget {
  /// Creates the physical unit detail screen.
  const UnitDetailScreen({
    required this.serialNumber,
    super.key,
  });

  /// The machine serial number scanned or looked up.
  final String serialNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unitAsync = ref.watch(_unitProvider(serialNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.unitDetailsTitle),
      ),
      body: unitAsync.when(
        loading: () => const _UnitDetailSkeleton(),
        error: (Object error, StackTrace stackTrace) => AppErrorState(
          failure: error is AppFailure
              ? error
              : UnexpectedFailure(cause: error, stackTrace: stackTrace),
          onRetry: () => ref.invalidate(_unitProvider(serialNumber)),
        ),
        data: (ProductUnit? unit) {
          if (unit == null) {
            return AppEmptyState(
              icon: Icons.qr_code_scanner_rounded,
              title: l10n.unitNotFoundTitle,
              message: l10n.unitNotFoundBody,
              actionLabel: l10n.actionClose,
              onAction: () => context.pop(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Product Summary Header
                _ProductHeaderCard(unit: unit),
                const SizedBox(height: Spacing.x4),

                // Physical Machine Information
                _MachineDetailsCard(unit: unit),
                const SizedBox(height: Spacing.x4),

                // Warranty Status & Details
                _WarrantyDetailsCard(unit: unit),
                const SizedBox(height: Spacing.x6),

                // Primary Action: Raise Complaint linked to Unit
                AppButton(
                  label: l10n.unitActionRaiseComplaint,
                  icon: Icons.report_problem_outlined,
                  onPressed: () {
                    context.push(
                      '/complaint/new?unitId=${unit.unitId}&reference=${Uri.encodeComponent(unit.serialNumber)}',
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final _unitProvider =
    FutureProvider.family<ProductUnit?, String>((ref, serial) async {
  final repository = ref.watch(unitRepositoryProvider);
  final result = await repository.findUnitBySerial(serial);
  return result.fold(
    onSuccess: (unit) => unit,
    onFailure: (failure) => throw failure,
  );
});

class _ProductHeaderCard extends StatelessWidget {
  const _ProductHeaderCard({required this.unit});

  final ProductUnit unit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Spacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(Spacing.x3),
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: AppRadius.cardAll,
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: Spacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      unit.productName,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (unit.modelNumber != null && unit.modelNumber!.isNotEmpty)
                      Text(
                        'Model: ${unit.modelNumber}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              AppBadge(
                label: unit.category.name.toUpperCase(),
                tone: AppBadgeTone.neutral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MachineDetailsCard extends StatelessWidget {
  const _MachineDetailsCard({required this.unit});

  final ProductUnit unit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      padding: const EdgeInsets.all(Spacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.unitSectionMachineTitle,
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: Spacing.x5),
          _DetailRow(
            label: l10n.unitLabelSerialNumber,
            value: unit.serialNumber,
            isMonospace: true,
            trailingIcon: Icons.copy_rounded,
            onTrailingTap: () {
              Clipboard.setData(ClipboardData(text: unit.serialNumber));
              AppSnackbar.show(context, l10n.unitSerialCopied);
            },
          ),
          const SizedBox(height: Spacing.x3),
          _DetailRow(
            label: l10n.unitLabelManufacturedAt,
            value: '${unit.manufacturedAt.day}/${unit.manufacturedAt.month}/${unit.manufacturedAt.year}',
          ),
        ],
      ),
    );
  }
}

class _WarrantyDetailsCard extends StatelessWidget {
  const _WarrantyDetailsCard({required this.unit});

  final ProductUnit unit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reg = unit.registration;
    final defaultMonths = unit.defaultWarrantyMonths ?? 12;

    return AppCard(
      padding: const EdgeInsets.all(Spacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.unitSectionWarrantyTitle,
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (reg != null)
                AppBadge(
                  label: reg.isExpired
                      ? l10n.warrantyStatusExpired
                      : l10n.warrantyStatusActive,
                  tone: reg.isExpired
                      ? AppBadgeTone.danger
                      : AppBadgeTone.success,
                )
              else
                AppBadge(
                  label: l10n.warrantyStatusUnactivated,
                  tone: AppBadgeTone.warning,
                ),
            ],
          ),
          const Divider(height: Spacing.x5),
          _DetailRow(
            label: l10n.warrantyLabelStandardCoverage,
            value: '$defaultMonths ${l10n.unitMonths}',
          ),
          if (reg != null) ...<Widget>[
            const SizedBox(height: Spacing.x3),
            _DetailRow(
              label: l10n.warrantyLabelCustomerName,
              value: reg.customerName ?? 'N/A',
            ),
            const SizedBox(height: Spacing.x3),
            _DetailRow(
              label: l10n.warrantyLabelCustomerPhone,
              value: reg.customerPhone ?? 'N/A',
            ),
            const SizedBox(height: Spacing.x3),
            _DetailRow(
              label: l10n.warrantyLabelInstallationDate,
              value: '${reg.installationDate.day}/${reg.installationDate.month}/${reg.installationDate.year}',
            ),
            const SizedBox(height: Spacing.x3),
            _DetailRow(
              label: l10n.warrantyLabelEndDate,
              value: '${reg.warrantyEndDate.day}/${reg.warrantyEndDate.month}/${reg.warrantyEndDate.year}',
            ),
            if (reg.invoiceNumber != null && reg.invoiceNumber!.isNotEmpty) ...<Widget>[
              const SizedBox(height: Spacing.x3),
              _DetailRow(
                label: l10n.warrantyLabelInvoiceNumber,
                value: reg.invoiceNumber!,
              ),
            ],
          ] else ...<Widget>[
            const SizedBox(height: Spacing.x3),
            Text(
              l10n.warrantyUnactivatedHelp,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
    this.trailingIcon,
    this.onTrailingTap,
  });

  final String label;
  final String value;
  final bool isMonospace;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: <Widget>[
            Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.bold,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
            if (trailingIcon != null) ...<Widget>[
              const SizedBox(width: Spacing.x2),
              InkWell(
                onTap: onTrailingTap,
                borderRadius: AppRadius.pillAll,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x1),
                  child: Icon(
                    trailingIcon,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _UnitDetailSkeleton extends StatelessWidget {
  const _UnitDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: Padding(
        padding: EdgeInsets.all(Spacing.x4),
        child: Column(
          children: <Widget>[
            AppSkeleton(height: 90, borderRadius: AppRadius.cardAll),
            SizedBox(height: Spacing.x4),
            AppSkeleton(height: 120, borderRadius: AppRadius.cardAll),
            SizedBox(height: Spacing.x4),
            AppSkeleton(height: 160, borderRadius: AppRadius.cardAll),
          ],
        ),
      ),
    );
  }
}
