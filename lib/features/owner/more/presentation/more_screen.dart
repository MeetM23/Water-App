import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/extensions/enum_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brand_wordmark.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/application/session_controller.dart';
import '../../settings/application/export_controller.dart';
import '../../settings/application/locale_controller.dart';

/// Account, tools, exports and sign-out.
class MoreScreen extends ConsumerWidget {
  /// Creates the More tab.
  const MoreScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.signOutConfirmTitle,
      message: l10n.signOutConfirmBody,
      confirmLabel: l10n.actionSignOut,
      isDestructive: true,
    );
    if (confirmed) {
      unawaited(ref.read(authControllerProvider.notifier).signOut());
    }
  }

  /// Runs an export and hands the result to the platform share sheet.
  ///
  /// Sharing rather than saving is deliberate: the client sends these to an
  /// accountant on WhatsApp, and a file dropped in Downloads is a file they
  /// then have to go and find.
  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    Future<({ExportedFile? file, dynamic failure})> Function() build,
  ) async {
    final l10n = context.l10n;
    final outcome = await build();

    if (!context.mounted) {
      return;
    }
    if (outcome.failure != null) {
      AppSnackbar.error(context, l10n.moreExportFailed);
      return;
    }
    if (outcome.file == null) {
      return;
    }

    final file = outcome.file!;
    try {
      await Share.shareXFiles(<XFile>[
        XFile.fromData(
          file.bytes,
          name: file.fileName,
          mimeType: file.mimeType,
        ),
      ]);
    } on Object catch (error, stackTrace) {
      AppLog.error('Sharing an export failed', error, stackTrace);
      if (context.mounted) {
        AppSnackbar.error(context, l10n.moreExportFailed);
      }
    }
  }

  Future<void> _openLanguagePicker(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final current = ref.read(localeControllerProvider);

    final selection = await showModalBottomSheet<_LanguageChoice>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(Spacing.x5),
              child: Text(
                l10n.languageTitle,
                style: sheetContext.textTheme.titleMedium,
              ),
            ),
            _LanguageTile(
              label: l10n.moreLanguageSystem,
              isSelected: current == null,
              onTap: () =>
                  Navigator.of(sheetContext).pop(const _LanguageChoice(null)),
            ),
            _LanguageTile(
              label: l10n.languageEnglish,
              isSelected: current?.languageCode == 'en',
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(const _LanguageChoice(Locale('en'))),
            ),
            _LanguageTile(
              label: l10n.languageGujarati,
              isSelected: current?.languageCode == 'gu',
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(const _LanguageChoice(Locale('gu'))),
            ),
            const SizedBox(height: Spacing.x3),
          ],
        ),
      ),
    );

    if (selection == null) {
      return;
    }
    await ref.read(localeControllerProvider.notifier).select(selection.locale);
  }

  Future<void> _contactSupport(BuildContext context) async {
    final launched = await ContactLauncher.openWhatsApp(
      prefilledMessage: 'Maruti Water app support',
    );
    if (!launched && context.mounted) {
      AppSnackbar.error(context, context.l10n.errorGenericTitle);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final profile = session is SessionSignedIn ? session.profile : null;
    final locale = ref.watch(localeControllerProvider);
    final running = ref.watch(exportControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const BrandWordmark.compact()),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.x4),
        children: <Widget>[
          _Header(label: l10n.moreAccount),
          if (profile != null)
            AppCard(
              onTap: () => context.push(AppRoutes.ownerProfile),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          profile.fullName,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.firmName,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.x2),
                  AppBadge(
                    label: profile.role.label(l10n),
                    tone: AppBadgeTone.info,
                  ),
                ],
              ),
            ),
          const SizedBox(height: Spacing.x3),
          _Group(
            children: <Widget>[
              _Row(
                icon: Icons.person_outline_rounded,
                label: l10n.moreProfile,
                onTap: () => context.push(AppRoutes.ownerProfile),
              ),
              _Row(
                icon: Icons.lock_outline_rounded,
                label: l10n.moreChangePassword,
                onTap: () => context.push(AppRoutes.ownerPassword),
              ),
            ],
          ),
          const SizedBox(height: Spacing.x6),
          _Header(label: l10n.moreTools),
          _Group(
            children: <Widget>[
              _Row(
                icon: Icons.confirmation_number_outlined,
                label: l10n.ownerComplaintsTitle,
                subtitle: l10n.ownerComplaintsSubtitle,
                onTap: () => context.push(AppRoutes.ownerComplaints),
              ),
              _Row(
                icon: Icons.view_carousel_outlined,
                label: l10n.manageBannersTitle,
                subtitle: l10n.manageBannersSubtitle,
                onTap: () => context.push(AppRoutes.ownerBanners),
              ),
              _Row(
                icon: Icons.app_registration_rounded,
                label: 'Product Registrations',
                subtitle: 'View registered RO units and customer warranties',
                onTap: () => context.push(AppRoutes.ownerRegistrations),
              ),
              _Row(
                icon: Icons.verified_outlined,
                label: 'Warranty Claims',
                subtitle: 'Manage dealer warranty claim requests',
                onTap: () => context.push(AppRoutes.ownerClaims),
              ),
              _Row(
                icon: Icons.storefront_outlined,
                label: l10n.moreBusinessDetails,
                subtitle: l10n.moreBusinessDetailsHelp,
                onTap: () => context.push(AppRoutes.ownerBusiness),
              ),



              _Row(
                icon: Icons.translate_rounded,
                label: l10n.moreLanguage,
                trailingLabel: switch (locale?.languageCode) {
                  'en' => l10n.languageEnglish,
                  'gu' => l10n.languageGujarati,
                  _ => l10n.moreLanguageSystem,
                },
                onTap: () => _openLanguagePicker(context, ref),
              ),
            ],
          ),
          const SizedBox(height: Spacing.x6),
          _Header(label: l10n.moreExportCatalogue),
          _Group(
            children: <Widget>[
              _Row(
                icon: Icons.picture_as_pdf_outlined,
                label: l10n.moreExportCatalogue,
                subtitle: l10n.moreExportCatalogueHelp,
                isBusy: running == ExportKind.catalogue,
                onTap: () => _export(
                  context,
                  ref,
                  ref.read(exportControllerProvider.notifier).catalogue,
                ),
              ),
              _Row(
                icon: Icons.table_chart_outlined,
                label: l10n.moreExportDealers,
                isBusy: running == ExportKind.dealers,
                onTap: () => _export(
                  context,
                  ref,
                  ref.read(exportControllerProvider.notifier).dealers,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.x6),
          _Header(label: l10n.moreAbout),
          _Group(
            children: <Widget>[
              _Row(
                icon: Icons.support_agent_outlined,
                label: l10n.moreSupport,
                subtitle: l10n.moreSupportHelp,
                onTap: () => _contactSupport(context),
              ),
            ],
          ),
          const SizedBox(height: Spacing.x3),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppConfig.companyName,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.moreVersion(AppConfig.appVersion),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.x6),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
              ),
              title: Text(
                l10n.actionSignOut,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.danger,
                ),
              ),
              onTap: () => _confirmSignOut(context, ref),
            ),
          ),
          const SizedBox(height: Spacing.x10),
        ],
      ),
    );
  }
}

/// Wraps a bottom sheet result so "the owner chose device language" is
/// distinguishable from "the owner dismissed the sheet". Both are null on
/// their own.
class _LanguageChoice {
  const _LanguageChoice(this.locale);

  final Locale? locale;
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (var index = 0; index < children.length; index++) ...<Widget>[
            if (index > 0) const Divider(height: 1, indent: Spacing.x10),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailingLabel,
    this.isBusy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final String? trailingLabel;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      isThreeLine: false,
      trailing: isBusy
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : trailingLabel == null
          ? const Icon(Icons.chevron_right_rounded)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    trailingLabel!,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
      onTap: isBusy ? null : onTap,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.x3),
    child: Text(
      label.toUpperCase(),
      style: context.textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    ),
  );
}
