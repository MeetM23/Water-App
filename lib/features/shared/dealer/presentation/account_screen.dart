import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/extensions/enum_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brand_wordmark.dart';
import '../../../../data/cache/hive_catalogue_cache.dart';
import '../../../../domain/models/profile.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/application/session_controller.dart';
import '../../../owner/settings/application/locale_controller.dart';
import '../../unit/presentation/user_claims_screen.dart';
import '../../unit/presentation/user_registrations_screen.dart';
import '../application/cache_status_controller.dart';
import '../application/catalogue_controller.dart';
import '../domain/dealer_experience.dart';


/// The dealer's own account: who they are, how the app behaves, and the way
/// out of it.
///
/// Everything about the profile is read-only. The firm name and phone on this
/// record are what Maruti Water Solution approved, and letting a dealer type
/// over them from a settings screen would quietly break the match between the
/// account and the paperwork behind it.
class DealerAccountScreen extends ConsumerWidget {
  /// Creates the account tab for one dealer role.
  const DealerAccountScreen({required this.experience, super.key});

  /// Supplies the path of this role's change-password screen. Nothing else on
  /// this screen differs between the two.
  final DealerExperience experience;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sessionAsync = ref.watch(sessionControllerProvider);
    final session = sessionAsync.valueOrNull;
    final profile = session is SessionSignedIn ? session.profile : null;
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const BrandWordmark.compact()),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.x4),
        children: <Widget>[
          _Header(label: l10n.moreAccount),
          if (sessionAsync.isLoading)
            const _ProfileSkeleton()
          else if (profile != null)
            _ProfileCard(profile: profile)
          else
            const _GuestProfileCard(),
          const SizedBox(height: Spacing.x3),
          _Group(
            children: <Widget>[
              _Row(
                icon: Icons.support_rounded,
                label: l10n.complaintsTitle,
                subtitle: l10n.complaintsSubtitle,
                onTap: () => profile == null
                    ? context.push('${AppRoutes.login}?from=${Uri.encodeComponent(AppRoutes.complaints)}')
                    : context.push(AppRoutes.complaints),
              ),
              _Row(
                icon: Icons.app_registration_rounded,
                label: 'My Registered Units',
                subtitle: 'View your registered physical machines',
                onTap: () => profile == null
                    ? context.push(AppRoutes.login)
                    : Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const UserRegistrationsScreen(),
                        ),
                      ),
              ),
              _Row(
                icon: Icons.verified_outlined,
                label: 'My Warranty Claims',
                subtitle: 'View status of your submitted warranty claims',
                onTap: () => profile == null
                    ? context.push(AppRoutes.login)
                    : Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const UserWarrantyClaimsScreen(),
                        ),
                      ),
              ),
              _Row(
                icon: Icons.lock_outline_rounded,
                label: l10n.moreChangePassword,
                onTap: () => profile == null
                    ? context.push(AppRoutes.login)
                    : context.push(experience.passwordRoute),
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
          _Header(label: l10n.accountCacheSection),
          const _CacheSection(),
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
                const SizedBox(height: Spacing.x1),
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
          if (profile != null)
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
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.login_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  l10n.loginSubmit,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                onTap: () => context.push(AppRoutes.login),
              ),
            ),
          const SizedBox(height: Spacing.x10),
        ],
      ),
    );
  }
}

/// Wraps a bottom sheet result so "the dealer chose device language" is
/// distinguishable from "the dealer dismissed the sheet". Both are null on
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

class _GuestProfileCard extends StatelessWidget {
  const _GuestProfileCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.loginTitle,
            style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: Spacing.x1),
          Text(
            l10n.loginSubtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.x4),
          AppButton(
            label: l10n.loginSubmit,
            onPressed: () => context.push(AppRoutes.login),
            icon: Icons.login_rounded,
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gst = profile.gstNumber?.trim();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            profile.fullName,
            style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: Spacing.x1),
          Text(
            profile.firmName,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.x3),
          // The badge sits on its own line rather than beside the name: at a
          // 2x text scale on a 320dp phone, a name and a pill sharing one row
          // leave the pill too little width to render a role in.
          AppBadge(label: profile.role.label(l10n), tone: AppBadgeTone.info),
          const SizedBox(height: Spacing.x4),
          _DetailRow(label: l10n.labelPhone, value: profile.phone),
          _DetailRow(
            label: l10n.labelCity,
            value: '${profile.city}, ${profile.state}',
          ),
          _DetailRow(
            label: l10n.dealerGstLabel,
            value: gst == null || gst.isEmpty ? l10n.dealerNoGst : gst,
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) => const AppCard(
    child: AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSkeleton(width: 160),
          SizedBox(height: Spacing.x2),
          AppSkeleton(width: 220, height: 10),
          SizedBox(height: Spacing.x5),
          AppSkeleton(height: 12),
          SizedBox(height: Spacing.x3),
          AppSkeleton(height: 12),
        ],
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// How much of the phone the offline catalogue is using, and the way to get it
/// back.
///
/// Split into its own widget so that measuring the cache — a walk over every
/// stored image — cannot hold up the rest of the account screen, which is
/// already in memory.
class _CacheSection extends ConsumerWidget {
  const _CacheSection();

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    // Resolved before the dialog: the cache itself must still be reachable to
    // finish the delete even if this tab is gone by the time the dealer taps
    // confirm.
    final cache = ref.read(catalogueCacheProvider);
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.accountClearCacheTitle,
      message: l10n.accountClearCacheBody,
      confirmLabel: l10n.accountClearCache,
      isDestructive: true,
    );
    if (!confirmed) {
      return;
    }

    await cache.clearCachedCatalogue();

    // A dealer who taps clear and immediately switches tabs would otherwise
    // reach a disposed WidgetRef here, which throws.
    if (!context.mounted) {
      return;
    }
    // The catalogue controller is kept alive and still holds the products that
    // were just deleted from disk. Without this invalidation the dealer clears
    // the cache, sees the catalogue unchanged, and clears it again.
    ref
      ..invalidate(catalogueControllerProvider)
      ..invalidate(cacheStatusProvider);

    AppSnackbar.success(context, l10n.accountCacheCleared);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(cacheStatusProvider);

    return status.when(
      loading: () => const AppCard(
        child: AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppSkeleton(width: 200),
              SizedBox(height: Spacing.x2),
              AppSkeleton(width: 120, height: 10),
            ],
          ),
        ),
      ),
      // A failed measurement is not worth a retry button. The cache itself is
      // fine and still serving the catalogue; only the number is missing, so
      // this stays one quiet line rather than an error state.
      error: (Object error, StackTrace stackTrace) => AppCard(
        child: Text(
          l10n.errorGenericBody,
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (CacheStatus value) {
        // Hoisted so the age line reads a promoted local rather than forcing a
        // `!` on a public field the analyser will not promote.
        final updatedAt = value.updatedAt;

        return AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(Spacing.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      value.hasCachedProducts
                          ? l10n.accountCacheStatus(
                              value.productCount,
                              _formatSize(value.sizeInBytes),
                            )
                          : l10n.accountCacheEmpty,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    if (updatedAt != null) ...<Widget>[
                      const SizedBox(height: Spacing.x1),
                      Text(
                        l10n.accountCacheUpdated(
                          RelativeTime.format(
                            l10n,
                            updatedAt,
                            now: ref.watch(nowProvider)(),
                          ),
                        ),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value.hasCachedProducts) ...<Widget>[
                const Divider(height: 1, indent: Spacing.x4),
                ListTile(
                  leading: const Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.danger,
                  ),
                  title: Text(
                    l10n.accountClearCache,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  // The subtitle repeats the promise the confirmation dialog
                  // makes, because what stops a dealer freeing space is the
                  // fear of losing the products they saved for a quote.
                  subtitle: Text(l10n.accountClearCacheBody),
                  onTap: () => _clear(context, ref),
                ),
              ],
            ],
          ),
        );
      },
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      isThreeLine: false,
      trailing: trailingLabel == null
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
      onTap: onTap,
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

/// Bytes as something a dealer can judge at a glance: '840 KB', '3.2 MB'.
///
/// The unit is a Dart literal because the ARB asks for one: the
/// `accountCacheStatus` placeholder `size` is a String documented with the
/// example '3.2 MB', keeping the unit out of translation the way every other
/// storage screen on the phone already does in Gujarati.
String _formatSize(int bytes) {
  const kilobyte = 1024;
  const megabyte = kilobyte * kilobyte;

  if (bytes < megabyte) {
    // Rounded up, not to nearest: a small but real cache reading as '0 KB'
    // looks like the clear button has already run.
    return '${(bytes / kilobyte).ceil()} KB';
  }
  return '${(bytes / megabyte).toStringAsFixed(1)} MB';
}
