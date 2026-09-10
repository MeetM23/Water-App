import 'package:flutter/foundation.dart';

import '../../../../domain/enums/user_role.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Everything that differs between the wholesaler build and the retailer build.
///
/// Both dealer roles run the same screens off the same controllers. Only three
/// things separate them: the paths they live on, the word printed above the
/// price, and the wording of the quotation they hand out. Naming those three
/// here — rather than forking the feature folder — is what keeps a fix to the
/// catalogue a fix for both roles rather than for whichever one was noticed.
///
/// This is emphatically NOT where the price comes from. `catalog_view` resolves
/// that from the caller's role inside the database and hands the app a single
/// figure with no second number beside it. This object only decides what to
/// call the figure that arrived.
@immutable
class DealerExperience {
  /// Creates the configuration for one dealer role.
  const DealerExperience({
    required this.role,
    required this.catalogueRoute,
    required this.scanRoute,
    required this.savedRoute,
    required this.accountRoute,
    required this.passwordRoute,
    required this.productRoute,
    required this.priceLabel,
    required this.quotation,
  });

  /// Which role this configuration serves.
  ///
  /// Carried so a test can assert that the screen it pumped is the one it meant
  /// to pump; nothing in the running app branches on it.
  final UserRole role;

  /// Path of the catalogue tab.
  final String catalogueRoute;

  /// Path of the scanner tab.
  final String scanRoute;

  /// Path of the saved-list tab.
  final String savedRoute;

  /// Path of the account tab.
  final String accountRoute;

  /// Path of the change-password screen under the account tab.
  final String passwordRoute;

  /// Builds the path of the product screen for a printed product code.
  final String Function(String productCode) productRoute;

  /// The label printed above the one price this role receives.
  ///
  /// A function of the localiser rather than a plain string because the label
  /// has to follow the device language, and the object is built long before
  /// any `BuildContext` exists.
  final String Function(AppLocalizations l10n) priceLabel;

  /// The wording of the quotation this role exports.
  final QuotationStyle quotation;
}

/// The wording that turns a saved list into one role's document.
///
/// The layout — letterhead, table, total, notes — is identical for both roles
/// and lives in the builder. Only the sentences below the total change, because
/// only the reader changes: a wholesaler's sheet goes to a trade buyer, and a
/// retailer's goes to the person who will use the machine.
@immutable
class QuotationStyle {
  /// Creates a document style.
  const QuotationStyle({required this.documentTitle, required this.notes});

  /// The heading beside the date, and the word in the running header.
  final String documentTitle;

  /// The paragraphs printed in the box under the total, in order.
  final List<String> notes;
}
