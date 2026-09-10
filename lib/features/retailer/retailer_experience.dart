import '../../core/router/app_routes.dart';
import '../../domain/enums/user_role.dart';
import '../../l10n/generated/app_localizations.dart';
import '../shared/dealer/domain/dealer_experience.dart';

/// The dealer build as a retailer sees it.
///
/// Every screen behind this object is the one the wholesaler build uses. The
/// figures on it are the retail figures because `catalog_view` resolved them
/// from the caller's role inside the database, not because anything here asked
/// for them.
const DealerExperience retailerExperience = DealerExperience(
  role: UserRole.retailer,
  catalogueRoute: AppRoutes.retailerCatalogue,
  scanRoute: AppRoutes.retailerScan,
  savedRoute: AppRoutes.retailerSaved,
  accountRoute: AppRoutes.retailerAccount,
  passwordRoute: AppRoutes.retailerPassword,
  productRoute: AppRoutes.retailerProduct,
  priceLabel: _priceLabel,
  quotation: _quotation,
);

String _priceLabel(AppLocalizations l10n) => l10n.labelRetailPrice;

/// The sheet a retailer hands to the customer standing in the shop.
///
/// It is read by someone who is buying one machine, not by a trade buyer
/// working from a price list, so it says what the figures cover and how long
/// they hold rather than talking about freight and order terms.
///
/// The validity note names no number of days. Nobody has set that policy, and a
/// period invented here would be quoted back at the client by a customer.
const QuotationStyle _quotation = QuotationStyle(
  documentTitle: 'Quotation',
  notes: <String>[
    'Each line is quoted for one unit. Quantities, taxes, delivery and '
        'installation charges are to be confirmed before an order is placed.',
    'Validity: the prices above hold on the date shown at the top of this '
        'quotation. Please confirm them with us before placing an order.',
  ],
);
