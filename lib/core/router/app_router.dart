import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/enums/account_status.dart';
import '../../domain/enums/complaint_category.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/models/profile.dart';
import '../../features/auth/application/session_controller.dart';
import '../../features/auth/presentation/account_blocked_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/pending_approval_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/dev/presentation/components_gallery_screen.dart';
import '../../features/complaints/presentation/screens/complaint_detail_screen.dart';
import '../../features/complaints/presentation/screens/create_complaint_screen.dart';
import '../../features/complaints/presentation/screens/user_complaints_screen.dart';
import '../../features/owner/banners/presentation/manage_banners_screen.dart';
import '../../features/owner/complaints/presentation/screens/owner_complaint_detail_screen.dart';

import '../../features/owner/complaints/presentation/screens/owner_complaints_screen.dart';
import '../../features/owner/dashboard/presentation/dashboard_screen.dart';
import '../../features/owner/dealers/presentation/approval_queue_screen.dart';
import '../../features/owner/dealers/presentation/dealer_detail_screen.dart';
import '../../features/owner/dealers/presentation/dealers_screen.dart';

import '../../features/owner/more/presentation/more_screen.dart';
import '../../features/owner/presentation/owner_shell.dart';
import '../../features/owner/print_labels/presentation/print_labels_page.dart';
import '../../features/owner/products/presentation/product_detail_screen.dart';
import '../../features/owner/products/presentation/product_form_screen.dart';
import '../../features/owner/products/presentation/product_list_screen.dart';
import '../../features/owner/settings/presentation/business_details_screen.dart';
import '../../features/owner/settings/presentation/change_password_screen.dart';
import '../../features/owner/settings/presentation/owner_profile_screen.dart';
import '../../features/retailer/retailer_experience.dart';
import '../../features/shared/dealer/domain/dealer_experience.dart';
import '../../features/shared/dealer/presentation/account_screen.dart';
import '../../features/shared/dealer/presentation/catalogue_screen.dart';
import '../../features/shared/dealer/presentation/change_password_screen.dart';
import '../../features/shared/dealer/presentation/dealer_shell.dart';
import '../../features/shared/dealer/presentation/product_detail_screen.dart';
import '../../features/shared/dealer/presentation/saved_screen.dart';
import '../../features/shared/scanner/presentation/scanner_screen.dart';
import '../../features/shared/unit/presentation/product_registration_screen.dart';
import '../../features/shared/unit/presentation/unit_detail_screen.dart';
import '../../features/shared/unit/presentation/user_claims_screen.dart';
import '../../features/shared/unit/presentation/user_registrations_screen.dart';
import '../../features/shared/unit/presentation/warranty_claim_screen.dart';
import '../../features/wholesaler/wholesaler_experience.dart';
import '../../features/owner/claims/presentation/admin_claim_detail_screen.dart';
import '../../features/owner/claims/presentation/admin_claims_screen.dart';
import '../../features/owner/registrations/presentation/admin_registrations_screen.dart';
import 'app_routes.dart';
import 'router_refresh_notifier.dart';

part 'app_router.g.dart';

// GoRouter manages branch and root navigator keys dynamically to prevent
// Flutter keyReservation assertion collisions when providers rebuild.

/// The application router.
///
/// Access is decided in one place, [_redirect], which runs on every navigation.
/// Screens therefore never check a role themselves, and a status change that
/// arrives mid-session moves the user immediately, because the session provider
/// notifies the refresh listenable.
///
/// None of this is a security boundary. It decides what to show; row level
/// security decides what can be read.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref<GoRouter> ref) {
  final refreshNotifier = RouterRefreshNotifier();

  ref.listen<AsyncValue<SessionState>>(
    sessionControllerProvider,
    (AsyncValue<SessionState>? previous, AsyncValue<SessionState> next) =>
        refreshNotifier.refresh(),
  );
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    // uri.path is the destination path outright. matchedLocation happens to
    // carry the same value for these flat routes, but it means "the portion
    // matched so far", which stops being the whole path once nested routes
    // arrive in a later phase. router_redirect_test.dart covers this table.
    redirect: (BuildContext context, GoRouterState state) =>
        _redirect(ref, state.uri.path),
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: AppRoutes.pending,
        builder: (_, __) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: AppRoutes.rejected,
        builder: (_, __) =>
            const AccountBlockedScreen(reason: BlockedReason.rejected),
      ),
      GoRoute(
        path: AppRoutes.suspended,
        builder: (_, __) =>
            const AccountBlockedScreen(reason: BlockedReason.suspended),
      ),
      // Complaint routes for authenticated dealers
      GoRoute(
        path: AppRoutes.complaints,
        builder: (_, __) => const UserComplaintsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createComplaint,
        builder: (BuildContext context, GoRouterState state) {
          final categoryStr = state.uri.queryParameters['category'];
          ComplaintCategory? category;
          if (categoryStr != null) {
            category = ComplaintCategory.values.firstWhere(
              (c) => c.name == categoryStr || c.value == categoryStr,
              orElse: () => ComplaintCategory.productIssue,
            );
          }
          return CreateComplaintScreen(
            initialUnitId: state.uri.queryParameters['unitId'],
            initialReference: state.uri.queryParameters['reference'],
            initialCategory: category,
          );
        },
      ),
      GoRoute(
        path: '/complaint/:id',
        builder: (BuildContext context, GoRouterState state) =>
            ComplaintDetailScreen(
              complaintId: state.pathParameters['id']!,
            ),
      ),
      // Owner Complaint Management routes
      GoRoute(
        path: AppRoutes.ownerComplaints,
        builder: (_, __) => const OwnerComplaintsScreen(),
      ),
      GoRoute(
        path: '/owner/complaints/:id',
        builder: (BuildContext context, GoRouterState state) =>
            OwnerComplaintDetailScreen(
              complaintId: state.pathParameters['id']!,
            ),
      ),
      GoRoute(
        path: '/owner/claims/:id',
        builder: (BuildContext context, GoRouterState state) =>
            AdminWarrantyClaimDetailScreen(
              claimId: state.pathParameters['id']!,
            ),
      ),
      GoRoute(
        path: AppRoutes.ownerPrintLabels,
        builder: (_, __) => const PrintLabelsPage(),
      ),
      GoRoute(
        path: AppRoutes.ownerBanners,
        builder: (_, __) => const ManageBannersScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerRegistrations,
        builder: (_, __) => const AdminRegistrationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerClaims,
        builder: (_, __) => const AdminWarrantyClaimsScreen(),
      ),


      // The owner area is a four-branch shell. Each branch keeps its own
      // navigation stack, so switching tabs does not lose a scroll position or
      // a half-read dealer record.
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => OwnerShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.owner,
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.ownerProducts,
                builder: (_, __) => const ProductListScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'new',
                    builder: (_, __) => const ProductFormScreen(),
                  ),
                  GoRoute(
                    path: ':productId',
                    builder: (BuildContext context, GoRouterState state) =>
                        ProductDetailScreen(
                          productId: state.pathParameters['productId']!,
                        ),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'edit',
                        builder: (BuildContext context, GoRouterState state) =>
                            ProductFormScreen(
                              productId: state.pathParameters['productId'],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.ownerDealers,
                builder: (_, __) => const DealersScreen(),
                routes: <RouteBase>[
                  // Declared before ':userId' so the literal wins: a dealer id
                  // is a uuid and can never be the word "requests", but
                  // relying on that rather than on order would be fragile.
                  GoRoute(
                    path: 'requests',
                    builder: (_, __) => const ApprovalQueueScreen(),
                  ),
                  GoRoute(
                    path: ':userId',
                    builder: (BuildContext context, GoRouterState state) =>
                        DealerDetailScreen(
                          userId: state.pathParameters['userId']!,
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.ownerMore,
                builder: (_, __) => const MoreScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'profile',
                    builder: (_, __) => const OwnerProfileScreen(),
                  ),
                  GoRoute(
                    path: 'password',
                    builder: (_, __) => const ChangePasswordScreen(),
                  ),
                  GoRoute(
                    path: 'business',
                    builder: (_, __) => const BusinessDetailsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // The two dealer areas. Both are built by the same function, because they
      // are the same four screens: only the paths they sit on and the wording
      // those screens carry differ, and a second hand-written copy of this tree
      // would be the first thing to drift out of step.
      _dealerShell(wholesalerExperience),
      _dealerProductRoute(wholesalerExperience),
      _dealerShell(retailerExperience),
      _dealerProductRoute(retailerExperience),
      GoRoute(
        path: AppRoutes.productRegistration,
        builder: (BuildContext context, GoRouterState state) =>
            ProductRegistrationScreen(
              initialSerial: state.uri.queryParameters['serialNumber'],
            ),
      ),
      GoRoute(
        path: AppRoutes.warrantyClaim,
        builder: (BuildContext context, GoRouterState state) =>
            WarrantyClaimScreen(
              initialSerial: state.uri.queryParameters['serialNumber'],
            ),
      ),
      GoRoute(
        path: AppRoutes.userRegistrations,
        builder: (_, __) => const UserRegistrationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.userClaims,
        builder: (_, __) => const UserWarrantyClaimsScreen(),
      ),
      GoRoute(
        path: '/unit/:serial',
        builder: (BuildContext context, GoRouterState state) =>
            UnitDetailScreen(serialNumber: state.pathParameters['serial']!),
      ),
      GoRoute(
        path: AppRoutes.components,
        builder: (_, __) => const ComponentsGalleryScreen(),
      ),
    ],
  );
}

/// The four-branch shell one dealer role lives in.
///
/// Each branch keeps its own navigation stack, so a dealer who scans a product
/// and then checks their saved list comes back to the product they were looking
/// at rather than to a fresh camera.
StatefulShellRoute _dealerShell(DealerExperience experience) {
  return StatefulShellRoute.indexedStack(
    builder:
        (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => DealerShell(navigationShell: navigationShell),
    branches: <StatefulShellBranch>[
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: experience.catalogueRoute,
            builder: (_, __) => CatalogueScreen(experience: experience),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: experience.scanRoute,
            builder: (_, __) =>
                ScannerScreen(productRoute: experience.productRoute),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: experience.savedRoute,
            builder: (_, __) => SavedScreen(experience: experience),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: experience.accountRoute,
            builder: (_, __) => DealerAccountScreen(experience: experience),
            routes: <RouteBase>[
              GoRoute(
                path: 'password',
                builder: (_, __) => const DealerChangePasswordScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Pushed on top of the shell so a product screen can be opened by code.
///
/// Outside the shell on purpose: it covers the whole UI including the
/// navigation bar. A dealer who scanned a label is looking at one product, and
/// the tab bar is not what they need next.
GoRoute _dealerProductRoute(DealerExperience experience) => GoRoute(
  // The pattern comes from the same function that builds real paths, with the
  // parameter name standing in for a code. Writing the literal out by hand
  // beside a builder that emits it states one fact twice, and the two halves
  // drift.
  path: experience.productRoute(':code'),
  builder: (BuildContext context, GoRouterState state) =>
      DealerProductDetailScreen(
        productCode: state.pathParameters['code']!,
        experience: experience,
      ),
);

String? _redirect(Ref<GoRouter> ref, String location) {
  // The gallery is a developer tool reached by typing the path. It is not part
  // of the signed-in experience and is never redirected away from.
  if (location == AppRoutes.components) {
    return null;
  }

  final session = ref.read(sessionControllerProvider);

  return session.when(
    // Hold on the splash screen until the restored session has resolved, so no
    // screen belonging to the wrong role is ever shown, even briefly.
    loading: () => location == AppRoutes.splash ? null : AppRoutes.splash,
    error: (Object _, StackTrace __) => _redirectForSignedOut(location),
    data: (SessionState sessionState) => switch (sessionState) {
      SessionSignedOut() => _redirectForSignedOut(location),
      SessionSignedIn(:final profile) => _redirectForProfile(profile, location),
    },
  );
}

String? _redirectForSignedOut(String location) {
  if (location == AppRoutes.splash) {
    return AppRoutes.wholesalerCatalogue;
  }
  final uri = Uri.parse(location);
  if (AppRoutes.isGuestPath(uri.path)) {
    return null;
  }
  return AppRoutes.login;
}

String? _redirectForProfile(Profile profile, String location) {
  final uri = Uri.parse(location);
  final fromParam = uri.queryParameters['from'];

  // Two values, not one. `area` is everything this role may reach; `landing`
  // is where they are sent when they are outside it. They differ for a
  // wholesaler, whose area is /wholesaler but whose landing tab is
  // /wholesaler/catalogue — collapsing them into a single prefix would bounce
  // the dealer off /wholesaler/product/<code> straight back to the grid on
  // every scan.
  final (String area, String landing) = switch (profile.status) {
    AccountStatus.pending => profile.role == UserRole.retailer
        ? (AppRoutes.retailer, AppRoutes.retailerCatalogue)
        : (AppRoutes.pending, AppRoutes.pending),
    AccountStatus.rejected => (AppRoutes.rejected, AppRoutes.rejected),
    AccountStatus.suspended => (AppRoutes.suspended, AppRoutes.suspended),
    AccountStatus.approved => switch (profile.role) {
      UserRole.owner => (AppRoutes.owner, AppRoutes.owner),
      UserRole.wholesaler => (
        AppRoutes.wholesaler,
        AppRoutes.wholesalerCatalogue,
      ),
      UserRole.retailer => (
        AppRoutes.retailer,
        AppRoutes.retailerCatalogue,
      ),
    },
  };

  // If logging in from a return route ('from' query parameter), redirect back to it if valid for role.
  if (fromParam != null && fromParam.isNotEmpty) {
    final fromUri = Uri.parse(fromParam);
    if (fromUri.path == landing ||
        fromUri.path.startsWith('$area/') ||
        fromUri.path == AppRoutes.complaints ||
        fromUri.path.startsWith('/complaint') ||
        fromUri.path.startsWith('/unit') ||
        fromUri.path == AppRoutes.productRegistration ||
        fromUri.path == AppRoutes.warrantyClaim ||
        fromUri.path == AppRoutes.userRegistrations ||
        fromUri.path == AppRoutes.userClaims) {
      return fromParam;
    }
  }

  // A prefix match on the area, not equality on the landing route: every area
  // has nested routes such as /owner/products/<id>/edit, and equality would
  // bounce the user back to the tab root on every push. The bare area path
  // itself is not a destination, so it falls through to the landing route.
  if (uri.path == landing ||
      uri.path.startsWith('$area/') ||
      uri.path == AppRoutes.complaints ||
      uri.path.startsWith('/complaint') ||
      uri.path.startsWith('/unit') ||
      uri.path == AppRoutes.productRegistration ||
      uri.path == AppRoutes.warrantyClaim ||
      uri.path == AppRoutes.userRegistrations ||
      uri.path == AppRoutes.userClaims ||
      uri.path.startsWith('/owner/claims/') ||
      uri.path.startsWith('/owner/complaints/')) {
    return null;
  }
  return landing;
}
