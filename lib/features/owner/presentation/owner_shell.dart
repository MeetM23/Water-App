import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/theme/app_colors.dart';
import '../dealers/application/approval_queue_controller.dart';

/// The owner area: four tabs that each keep their own navigation stack.
///
/// Moving between tabs preserves where the owner was inside each one, so
/// stepping out to check a dealer does not lose their place in a long
/// catalogue scroll.
///
/// The Dealers tab carries a badge with the pending count. It lives on the tab
/// rather than inside the dealers screen so a waiting registration is visible
/// from anywhere in the app, which is the only place it is any use: nobody
/// opens the dealer directory to find out whether they should open it.
class OwnerShell extends ConsumerWidget {
  /// Creates the shell around [navigationShell].
  const OwnerShell({required this.navigationShell, super.key});

  /// The indexed stack go_router manages for the four branches.
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    // Tapping the tab you are already on pops that branch back to its root,
    // which is the behaviour every Android user already expects.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pending = ref.watch(pendingDealerCountProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard_rounded),
              label: l10n.navDashboard,
            ),
            NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2_rounded),
              label: l10n.navProducts,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pending > 0,
                label: Text('$pending'),
                backgroundColor: AppColors.warning,
                child: const Icon(Icons.people_alt_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: pending > 0,
                label: Text('$pending'),
                backgroundColor: AppColors.warning,
                child: const Icon(Icons.people_alt_rounded),
              ),
              label: l10n.navDealers,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz_rounded),
              selectedIcon: const Icon(Icons.more_horiz_rounded),
              label: l10n.navMore,
            ),
          ],
        ),
      ),
    );
  }
}
