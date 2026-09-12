import '../../../auth/application/session_controller.dart';
import '../../../../domain/enums/user_role.dart';

/// How the price section should be presented based on who is viewing.
///
/// - [mrpOnly]     — guest / not signed in. The raw MRP (maximum retail price)
///                   is shown so an anonymous visitor can see the list price
///                   without seeing either dealer rate.
/// - [wholesaleOnly] — wholesaler. Shows the wholesale price exactly as the
///                   admin set it, with no MRP or discount badge.
/// - [retailerWithDiscount] — retailer. Shows the MRP, the retailer price and
///                   the saving as a percentage so the dealer can communicate
///                   the discount to their customer.
enum PriceViewMode {
  mrpOnly,
  wholesaleOnly,
  retailerWithDiscount,
}

/// Resolves [PriceViewMode] from the current [SessionState].
///
/// Called in every screen that renders a price, keeping the mapping in one
/// place rather than scattered across widgets.
PriceViewMode priceViewModeFromSession(SessionState? session) {
  if (session is SessionSignedIn) {
    return switch (session.profile.role) {
      UserRole.retailer => PriceViewMode.retailerWithDiscount,
      UserRole.wholesaler => PriceViewMode.wholesaleOnly,
      UserRole.owner => PriceViewMode.wholesaleOnly,
    };
  }
  // Signed out or session still loading → show MRP only.
  return PriceViewMode.mrpOnly;
}
