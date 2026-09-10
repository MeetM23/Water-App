import '../../core/router/app_routes.dart';
import '../../domain/enums/user_role.dart';
import '../../l10n/generated/app_localizations.dart';
import '../shared/dealer/domain/dealer_experience.dart';

/// The dealer build as a wholesaler sees it.
const DealerExperience wholesalerExperience = DealerExperience(
  role: UserRole.wholesaler,
  catalogueRoute: AppRoutes.wholesalerCatalogue,
  scanRoute: AppRoutes.wholesalerScan,
  savedRoute: AppRoutes.wholesalerSaved,
  accountRoute: AppRoutes.wholesalerAccount,
  passwordRoute: AppRoutes.wholesalerPassword,
  productRoute: AppRoutes.wholesalerProduct,
  priceLabel: _priceLabel,
  quotation: _quotation,
);

String _priceLabel(AppLocalizations l10n) => l10n.labelWholesalePrice;

/// The sheet a wholesaler forwards to a trade buyer.
///
/// It says plainly that the total is not a settled figure, because the saved
/// list carries no quantities and the table therefore shows one of each. Left
/// unsaid, the total reads as a price agreed and the dealer spends the next
/// call explaining that it is not.
const QuotationStyle _quotation = QuotationStyle(
  documentTitle: 'Quotation',
  notes: <String>[
    'Each line is quoted for one unit. Quantities, taxes, freight and '
        'delivery dates are to be confirmed before an order is placed. Prices '
        'are valid on the date shown above.',
  ],
);
