import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The dealer area: four tabs that each keep their own navigation stack.
///
/// Scan is drawn as a raised, brand-coloured action rather than as a fourth
/// equal icon. Scanning is the reason this user opens the app at all — they
/// are standing at a shelf with a phone in one hand — so it is the one target
/// that must be hittable without looking. The other three are ordinary tabs.
class DealerShell extends StatelessWidget {
  /// Creates the shell around [navigationShell].
  const DealerShell({required this.navigationShell, super.key});

  /// The indexed stack go_router manages for the four branches.
  final StatefulNavigationShell navigationShell;

  /// Which branch is the raised scan action.
  static const int scanIndex = 1;

  void _onDestinationSelected(int index) {
    // Tapping the tab you are already on pops that branch to its root, which
    // is what every Android user expects. It also gives the scanner a cheap
    // way back to a clean camera from a product it navigated to.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _DealerNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onSelected: _onDestinationSelected,
        items: <_NavItem>[
          _NavItem(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view_rounded,
            label: l10n.navCatalogue,
          ),
          _NavItem(
            icon: Icons.qr_code_scanner_rounded,
            selectedIcon: Icons.qr_code_scanner_rounded,
            label: l10n.navScan,
          ),
          _NavItem(
            icon: Icons.bookmark_border_rounded,
            selectedIcon: Icons.bookmark_rounded,
            label: l10n.navSaved,
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.navAccount,
          ),
        ],
      ),
    );
  }
}

/// One destination in the dealer navigation bar.
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// A four-slot bar whose scan slot is raised out of the bar.
///
/// Hand-built rather than a [NavigationBar] because Material's bar gives every
/// destination identical weight, and the whole point here is that one of them
/// does not have identical weight.
class _DealerNavigationBar extends StatelessWidget {
  const _DealerNavigationBar({
    required this.currentIndex,
    required this.onSelected,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.x2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: index == DealerShell.scanIndex
                      ? _RaisedScanSlot(
                          item: items[index],
                          isSelected: currentIndex == index,
                          onTap: () => onSelected(index),
                        )
                      : _TabSlot(
                          item: items[index],
                          isSelected: currentIndex == index,
                          onTap: () => onSelected(index),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabSlot extends StatelessWidget {
  const _TabSlot({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = isSelected ? AppColors.primary : AppColors.textSecondary;

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.x2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(isSelected ? item.selectedIcon : item.icon,
                  size: 24, color: tone),
              const SizedBox(height: Spacing.x1),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(color: tone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The scan slot: a filled brand circle that breaks the top of the bar.
class _RaisedScanSlot extends StatelessWidget {
  const _RaisedScanSlot({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.x1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryDark : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.32),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.surface,
                  size: 24,
                ),
              ),
              const SizedBox(height: Spacing.x1),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
