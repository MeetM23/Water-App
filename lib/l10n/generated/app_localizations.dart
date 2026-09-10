import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu')
  ];

  /// Application name shown on the launcher and app bars.
  ///
  /// In en, this message translates to:
  /// **'Maruti Water'**
  String get appName;

  /// Button that re-runs a failed operation.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// Dismisses a dialog without acting.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Ends the current session.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get actionSignOut;

  /// Reloads the current screen.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// Confirms and proceeds.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// Headline for an unclassified failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// Body text for an unclassified failure.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that just now. Please try again.'**
  String get errorGenericBody;

  /// Headline shown when the device is offline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNetworkTitle;

  /// Body text shown when the device is offline.
  ///
  /// In en, this message translates to:
  /// **'Check your mobile data or Wi-Fi, then try again.'**
  String get errorNetworkBody;

  /// Headline for a backend failure.
  ///
  /// In en, this message translates to:
  /// **'Maruti Water is not responding'**
  String get errorServerTitle;

  /// Body text for a backend failure.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Please try again in a moment.'**
  String get errorServerBody;

  /// Headline when the server refuses for rate limiting.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts'**
  String get errorRateLimitedTitle;

  /// Body text when the server refuses for rate limiting.
  ///
  /// In en, this message translates to:
  /// **'Please wait a few minutes before trying again.'**
  String get errorRateLimitedBody;

  /// Headline when the auth token could not be refreshed.
  ///
  /// In en, this message translates to:
  /// **'You have been signed out'**
  String get errorSessionExpiredTitle;

  /// Body text when the auth token could not be refreshed.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get errorSessionExpiredBody;

  /// Inline error under an empty required field.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String validationRequired(String field);

  /// Inline error for a malformed email.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmail;

  /// Inline error for a malformed Indian mobile number.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit mobile number'**
  String get validationPhone;

  /// Inline error for a short password.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get validationPassword;

  /// Inline error for a malformed GSTIN.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 15-character GST number'**
  String get validationGst;

  /// Inline error for a field below its minimum length.
  ///
  /// In en, this message translates to:
  /// **'Enter at least {count} characters'**
  String validationTooShort(int count);

  /// Login screen headline.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// Login screen supporting line.
  ///
  /// In en, this message translates to:
  /// **'Maruti Water Solution dealer portal'**
  String get loginSubtitle;

  /// Login submit button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// Prompt above the sign-up link.
  ///
  /// In en, this message translates to:
  /// **'New dealer?'**
  String get loginNoAccount;

  /// Link to the sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccount;

  /// Shown when credentials are rejected.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get loginFailed;

  /// Sign-up screen headline.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signupTitle;

  /// Sign-up screen supporting line setting the approval expectation.
  ///
  /// In en, this message translates to:
  /// **'Maruti Water Solution reviews every new dealer before the account is activated.'**
  String get signupSubtitle;

  /// Sign-up submit button.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupSubmit;

  /// Prompt above the sign-in link.
  ///
  /// In en, this message translates to:
  /// **'Already registered?'**
  String get signupHaveAccount;

  /// Link back to the login screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signupSignIn;

  /// Shown when the email is already registered.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email address.'**
  String get signupEmailTaken;

  /// Label above the role selector.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get signupAccountType;

  /// Section header for credential fields.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get signupSectionAccount;

  /// Section header for firm fields.
  ///
  /// In en, this message translates to:
  /// **'Business details'**
  String get signupSectionBusiness;

  /// Sign-up field label.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// Sign-up field label for the business name.
  ///
  /// In en, this message translates to:
  /// **'Firm name'**
  String get fieldFirmName;

  /// Sign-up field label.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get fieldPhone;

  /// Login and sign-up field label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// Login and sign-up field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// Sign-up field label.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get fieldCity;

  /// Sign-up field label.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get fieldState;

  /// Sign-up field label for the optional GSTIN.
  ///
  /// In en, this message translates to:
  /// **'GST number'**
  String get fieldGstNumber;

  /// Suffix marking a field as not required.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get fieldOptional;

  /// Placeholder inside the phone field.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get hintPhone;

  /// Placeholder showing GSTIN shape.
  ///
  /// In en, this message translates to:
  /// **'24ABCDE1234F1Z5'**
  String get hintGstNumber;

  /// Role name.
  ///
  /// In en, this message translates to:
  /// **'Wholesaler'**
  String get roleWholesaler;

  /// Explains what the wholesaler role grants.
  ///
  /// In en, this message translates to:
  /// **'You will see wholesale pricing'**
  String get roleWholesalerHelp;

  /// Role name.
  ///
  /// In en, this message translates to:
  /// **'Retailer'**
  String get roleRetailer;

  /// Explains what the retailer role grants.
  ///
  /// In en, this message translates to:
  /// **'You will see retail pricing'**
  String get roleRetailerHelp;

  /// Headline on the pending-approval screen.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get pendingTitle;

  /// Calm explanation of why access is withheld.
  ///
  /// In en, this message translates to:
  /// **'Maruti Water Solution checks every new dealer account by hand. You will be able to sign in as soon as yours is approved.'**
  String get pendingBody;

  /// Label above the firm name the user signed up with.
  ///
  /// In en, this message translates to:
  /// **'Registered firm'**
  String get pendingFirmLabel;

  /// Refreshes the account status from the server.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get pendingCheckStatus;

  /// Result of a status check that found no change.
  ///
  /// In en, this message translates to:
  /// **'Your account is still awaiting approval.'**
  String get pendingStillWaiting;

  /// Headline on the rejected screen.
  ///
  /// In en, this message translates to:
  /// **'Account not approved'**
  String get rejectedTitle;

  /// Body text on the rejected screen.
  ///
  /// In en, this message translates to:
  /// **'Maruti Water Solution did not approve this account.'**
  String get rejectedBody;

  /// Label above the owner-supplied rejection reason.
  ///
  /// In en, this message translates to:
  /// **'Reason given'**
  String get rejectedReasonLabel;

  /// Fallback when the owner left no reason.
  ///
  /// In en, this message translates to:
  /// **'No reason was recorded.'**
  String get rejectedNoReason;

  /// Headline on the suspended screen.
  ///
  /// In en, this message translates to:
  /// **'Account suspended'**
  String get suspendedTitle;

  /// Body text on the suspended screen.
  ///
  /// In en, this message translates to:
  /// **'Access to this account has been paused by Maruti Water Solution. Get in touch to have it restored.'**
  String get suspendedBody;

  /// Opens a WhatsApp chat with the client.
  ///
  /// In en, this message translates to:
  /// **'Contact us on WhatsApp'**
  String get contactWhatsApp;

  /// Shown when no WhatsApp handler is installed.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp could not be opened on this device.'**
  String get contactUnavailable;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// Confirmation dialog body.
  ///
  /// In en, this message translates to:
  /// **'You will need your email and password to sign in again.'**
  String get signOutConfirmBody;

  /// Default empty-state headline.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyDefaultTitle;

  /// Default empty-state body.
  ///
  /// In en, this message translates to:
  /// **'Once there is something to show, it will appear here.'**
  String get emptyDefaultBody;

  /// Reveals a hidden password.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get actionShow;

  /// Hides a revealed password.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get actionHide;

  /// Empties the search box.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// App bar title on the signed-in overview.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get homeTitle;

  /// Confirms the session is active and approved.
  ///
  /// In en, this message translates to:
  /// **'You are signed in'**
  String get homeSignedInTitle;

  /// Explains what an approved dealer can expect next.
  ///
  /// In en, this message translates to:
  /// **'Your account is approved. The catalogue arrives in the next release.'**
  String get homeSignedInBody;

  /// Field label on the account overview.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get labelRole;

  /// Field label on the account overview.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// Field label on the account overview.
  ///
  /// In en, this message translates to:
  /// **'Firm'**
  String get labelFirm;

  /// Field label on the account overview.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get labelPhone;

  /// Field label on the account overview.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get labelCity;

  /// Role name for Maruti Water Solution staff.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// Account status badge.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Account status badge.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// Account status badge.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// Account status badge.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// Placeholder inside the email field.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get hintEmail;

  /// Bottom navigation label.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Bottom navigation label.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// Bottom navigation label.
  ///
  /// In en, this message translates to:
  /// **'Dealers'**
  String get navDealers;

  /// Bottom navigation label.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// Submits a form.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Confirms a destructive action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Opens the edit form.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Applies the chosen filters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// Clears the chosen filters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// Copies a value to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// Shares a file with another app.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// Opens the system print dialog.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get actionPrint;

  /// Dismisses a completion sheet.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Removes an item from a list.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// Opens the full list.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get actionViewAll;

  /// Dashboard stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get statTotalProducts;

  /// Dashboard stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get statOutOfStock;

  /// Dashboard stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statInactive;

  /// Dashboard stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Pending dealers'**
  String get statPendingDealers;

  /// Section header on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get dashboardQuickActions;

  /// Section header on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get dashboardRecentProducts;

  /// Opens the new-product form.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get actionAddProduct;

  /// Opens the label printing screen.
  ///
  /// In en, this message translates to:
  /// **'Print labels'**
  String get actionPrintLabels;

  /// Opens the dealer list.
  ///
  /// In en, this message translates to:
  /// **'Review dealers'**
  String get actionReviewDealers;

  /// App bar title on the product list.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// Placeholder in the product search field.
  ///
  /// In en, this message translates to:
  /// **'Search name, model or code'**
  String get searchProductsHint;

  /// Title of the filter bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Filter and sort'**
  String get filterTitle;

  /// Filter group label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// Filter group label.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get filterStatus;

  /// Filter group label.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSort;

  /// Filter chip covering every category.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get categoryAll;

  /// Product category name.
  ///
  /// In en, this message translates to:
  /// **'Domestic'**
  String get categoryDomestic;

  /// Product category name.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get categoryCommercial;

  /// Product category name.
  ///
  /// In en, this message translates to:
  /// **'Industrial'**
  String get categoryIndustrial;

  /// Product category name.
  ///
  /// In en, this message translates to:
  /// **'Spare part'**
  String get categorySparePart;

  /// Product category name.
  ///
  /// In en, this message translates to:
  /// **'Accessory'**
  String get categoryAccessory;

  /// Availability filter option.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// Availability filter option.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// Availability filter option.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactiveFilter;

  /// Availability filter option.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get statusOutOfStockFilter;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Price, low to high'**
  String get sortPriceLowHigh;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Price, high to low'**
  String get sortPriceHighLow;

  /// Price label on a product card.
  ///
  /// In en, this message translates to:
  /// **'Wholesale'**
  String get labelWholesale;

  /// Price label on a product card.
  ///
  /// In en, this message translates to:
  /// **'Retail'**
  String get labelRetail;

  /// Maximum retail price label.
  ///
  /// In en, this message translates to:
  /// **'MRP'**
  String get labelMrp;

  /// Label above the calculated margin.
  ///
  /// In en, this message translates to:
  /// **'Dealer margin'**
  String get labelMargin;

  /// Availability badge.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get badgeInStock;

  /// Availability badge.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get badgeOutOfStock;

  /// Status badge for a hidden product.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get badgeInactive;

  /// Empty state headline on the product list.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productsEmptyTitle;

  /// Empty state body on the product list.
  ///
  /// In en, this message translates to:
  /// **'Add your first product and the database will issue its permanent barcode.'**
  String get productsEmptyBody;

  /// Empty state headline when filters exclude everything.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches that'**
  String get productsNoResultsTitle;

  /// Empty state body when filters exclude everything.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term, or clear the filters to see the whole catalogue.'**
  String get productsNoResultsBody;

  /// Resets search and filters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get productsClearFilters;

  /// Quick action on a product card.
  ///
  /// In en, this message translates to:
  /// **'Toggle stock'**
  String get quickToggleStock;

  /// Quick action on a product card.
  ///
  /// In en, this message translates to:
  /// **'Toggle active'**
  String get quickToggleActive;

  /// Quick action on a product card.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get quickDuplicate;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete product?'**
  String get deleteProductTitle;

  /// Confirmation dialog body naming the product.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from the catalogue along with its photos. This cannot be undone.'**
  String deleteProductBody(String name);

  /// Snackbar after deleting a product.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String productDeleted(String name);

  /// Snackbar after duplicating a product.
  ///
  /// In en, this message translates to:
  /// **'{name} duplicated'**
  String productDuplicated(String name);

  /// Snackbar after an edit is stored.
  ///
  /// In en, this message translates to:
  /// **'Product saved'**
  String get productSaved;

  /// App bar title when creating.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get formNewTitle;

  /// App bar title when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get formEditTitle;

  /// Form section header.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get sectionPhotos;

  /// Form section header.
  ///
  /// In en, this message translates to:
  /// **'Basic details'**
  String get sectionBasics;

  /// Form section header.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get sectionSpecifications;

  /// Form section header.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get sectionPricing;

  /// Form section header.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get sectionAvailability;

  /// Helper text under the photo grid.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} photos. The first is used on the catalogue card.'**
  String photosHelp(int count);

  /// Opens the camera or gallery chooser.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get photosAdd;

  /// Badge on the image used as the product thumbnail.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get photosPrimary;

  /// Makes an image the product thumbnail.
  ///
  /// In en, this message translates to:
  /// **'Set as primary'**
  String get photosSetPrimary;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Remove photo?'**
  String get photosRemoveTitle;

  /// Confirmation dialog body.
  ///
  /// In en, this message translates to:
  /// **'This photo will not be saved with the product.'**
  String get photosRemoveBody;

  /// Shown when the photo limit is hit.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to {count} photos.'**
  String photosLimitReached(int count);

  /// Shown on a failed image upload.
  ///
  /// In en, this message translates to:
  /// **'That photo could not be uploaded. Tap to try again.'**
  String get photosUploadFailed;

  /// Helper text explaining drag to reorder.
  ///
  /// In en, this message translates to:
  /// **'Press and hold a photo to reorder.'**
  String get photosReorderHint;

  /// Title of the camera or gallery chooser sheet.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get chooseSourceTitle;

  /// Chooser option.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get sourceCamera;

  /// Chooser option.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get sourceGallery;

  /// Headline when the camera permission is refused.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get permissionCameraTitle;

  /// Body explaining why the camera is needed.
  ///
  /// In en, this message translates to:
  /// **'Maruti Water needs the camera to photograph a product. You can turn it on in Settings.'**
  String get permissionCameraBody;

  /// Sends the user to the system settings page.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permissionOpenSettings;

  /// Shown when the settings screen will not open.
  ///
  /// In en, this message translates to:
  /// **'Settings could not be opened on this device.'**
  String get permissionSettingsFailed;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get fieldProductName;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Model number'**
  String get fieldModelNumber;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategoryLabel;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get fieldCapacity;

  /// Helper text under the capacity field.
  ///
  /// In en, this message translates to:
  /// **'For example 25 LPH, or 12 L'**
  String get capacityHelp;

  /// Stepper field label.
  ///
  /// In en, this message translates to:
  /// **'Warranty (months)'**
  String get fieldWarrantyMonths;

  /// Price field label.
  ///
  /// In en, this message translates to:
  /// **'MRP'**
  String get fieldMrpLabel;

  /// Price field label.
  ///
  /// In en, this message translates to:
  /// **'Wholesale price'**
  String get fieldWholesaleLabel;

  /// Price field label.
  ///
  /// In en, this message translates to:
  /// **'Retail price'**
  String get fieldRetailLabel;

  /// Sub-heading above the key and value rows.
  ///
  /// In en, this message translates to:
  /// **'Detailed specifications'**
  String get specDetailsLabel;

  /// Adds an empty key and value row.
  ///
  /// In en, this message translates to:
  /// **'Add specification'**
  String get specAddRow;

  /// Placeholder for a specification name.
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get specKeyHint;

  /// Placeholder for a specification value.
  ///
  /// In en, this message translates to:
  /// **'7'**
  String get specValueHint;

  /// Empty state inside the specifications section.
  ///
  /// In en, this message translates to:
  /// **'No specifications yet. Add rows such as Membrane or Body material.'**
  String get specEmpty;

  /// Toggle label.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get fieldInStockLabel;

  /// Toggle helper text.
  ///
  /// In en, this message translates to:
  /// **'Dealers see this product as available to order.'**
  String get fieldInStockHelp;

  /// Toggle label.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get fieldActiveLabel;

  /// Toggle helper text.
  ///
  /// In en, this message translates to:
  /// **'Inactive products are hidden from every dealer catalogue.'**
  String get fieldActiveHelp;

  /// Blocking price error.
  ///
  /// In en, this message translates to:
  /// **'Retail price cannot be below the wholesale price'**
  String get priceErrorRetailBelowWholesale;

  /// Blocking price error.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get priceErrorNotPositive;

  /// Non-blocking price warning.
  ///
  /// In en, this message translates to:
  /// **'This price is above the MRP you entered'**
  String get priceWarningAboveMrp;

  /// Non-blocking price warning.
  ///
  /// In en, this message translates to:
  /// **'Retail equals wholesale, so the dealer earns nothing'**
  String get priceWarningZeroMargin;

  /// Live dealer margin chip on the pricing section.
  ///
  /// In en, this message translates to:
  /// **'{amount} margin ({percent}%)'**
  String marginChip(String amount, String percent);

  /// Shown while the margin cannot be computed.
  ///
  /// In en, this message translates to:
  /// **'Enter both prices to see the margin'**
  String get marginUnavailable;

  /// Confirmation on leaving a dirty form.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get unsavedTitle;

  /// Body of the discard confirmation.
  ///
  /// In en, this message translates to:
  /// **'Your edits to this product have not been saved.'**
  String get unsavedBody;

  /// Leaves the form and loses the edits.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get unsavedDiscard;

  /// Stays on the form.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get unsavedKeepEditing;

  /// Explains why save is disabled.
  ///
  /// In en, this message translates to:
  /// **'Wait for the photos to finish uploading'**
  String get formUploadsInFlight;

  /// Headline of the success sheet.
  ///
  /// In en, this message translates to:
  /// **'Product created'**
  String get createdTitle;

  /// Explains what the code is for.
  ///
  /// In en, this message translates to:
  /// **'This code is permanent and is now printed on every label for this product.'**
  String get createdBody;

  /// Label above the generated code.
  ///
  /// In en, this message translates to:
  /// **'Product code'**
  String get createdCodeLabel;

  /// Snackbar after copying the code.
  ///
  /// In en, this message translates to:
  /// **'Product code copied'**
  String get createdCopied;

  /// Caption under the linear barcode.
  ///
  /// In en, this message translates to:
  /// **'Code 128'**
  String get barcodeCode128;

  /// Caption under the QR code.
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get barcodeQr;

  /// Number of times dealers scanned this product.
  ///
  /// In en, this message translates to:
  /// **'{count} scans'**
  String detailScanCount(int count);

  /// Section header on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get detailSpecifications;

  /// Shown when the jsonb map is empty.
  ///
  /// In en, this message translates to:
  /// **'No specifications recorded.'**
  String get detailNoSpecifications;

  /// Section header on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detailDescription;

  /// Section header on the detail screen.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get detailPricing;

  /// Warranty summary.
  ///
  /// In en, this message translates to:
  /// **'{count} months warranty'**
  String detailWarranty(int count);

  /// Empty state in the image gallery.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get detailNoImages;

  /// App bar title on the label screen.
  ///
  /// In en, this message translates to:
  /// **'Print labels'**
  String get labelsTitle;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Select products'**
  String get labelsSelectProducts;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Sheet layout'**
  String get labelsLayout;

  /// Quantity stepper label.
  ///
  /// In en, this message translates to:
  /// **'Labels per product'**
  String get labelsQuantity;

  /// How many products are chosen.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String labelsSelectedCount(int count);

  /// Summary of the generated job.
  ///
  /// In en, this message translates to:
  /// **'{labels} labels across {sheets} sheets'**
  String labelsSummary(int labels, int sheets);

  /// Opens the PDF preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get labelsPreview;

  /// Empty state headline.
  ///
  /// In en, this message translates to:
  /// **'Choose products to label'**
  String get labelsEmptyTitle;

  /// Empty state body.
  ///
  /// In en, this message translates to:
  /// **'Pick one or more products and set how many labels each one needs.'**
  String get labelsEmptyBody;

  /// Empty state when the catalogue is empty.
  ///
  /// In en, this message translates to:
  /// **'No products to label'**
  String get labelsNoProductsTitle;

  /// Empty state body when the catalogue is empty.
  ///
  /// In en, this message translates to:
  /// **'Add a product first and it will appear here ready to print.'**
  String get labelsNoProductsBody;

  /// Caution on a layout whose barcode is too fine to scan reliably.
  ///
  /// In en, this message translates to:
  /// **'Bars print at {width} mm on this stock. Handheld scanners need about {minimum} mm, so scan a test label before printing a full run.'**
  String labelsBarcodeTooFine(String width, String minimum);

  /// Shown when the label list inherits an active catalogue filter.
  ///
  /// In en, this message translates to:
  /// **'Showing the products your catalogue filters currently match. Clear them on the Products tab to see everything.'**
  String get labelsFilterNotice;

  /// Shown when PDF building fails.
  ///
  /// In en, this message translates to:
  /// **'The label sheet could not be generated.'**
  String get labelsGenerateFailed;

  /// App bar title on the dealer screen.
  ///
  /// In en, this message translates to:
  /// **'Dealers'**
  String get dealersTitle;

  /// Dealer list tab.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dealersTabPending;

  /// Dealer list tab.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get dealersTabApproved;

  /// Dealer list tab.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get dealersTabRejected;

  /// Dealer list tab.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get dealersTabSuspended;

  /// Empty state headline for the pending tab.
  ///
  /// In en, this message translates to:
  /// **'No one is waiting'**
  String get dealersEmptyPendingTitle;

  /// Empty state body for the pending tab.
  ///
  /// In en, this message translates to:
  /// **'New dealer sign-ups will appear here for you to approve or turn down.'**
  String get dealersEmptyPendingBody;

  /// Empty state headline for the other tabs.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this list'**
  String get dealersEmptyTitle;

  /// Empty state body for the other tabs.
  ///
  /// In en, this message translates to:
  /// **'Dealers you move into this state will be listed here.'**
  String get dealersEmptyBody;

  /// Approves a dealer.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get dealerApprove;

  /// Turns a dealer down.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get dealerReject;

  /// Pauses an approved dealer.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get dealerSuspend;

  /// Restores a dealer.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get dealerReactivate;

  /// Title of the approve sheet.
  ///
  /// In en, this message translates to:
  /// **'Approve as which role?'**
  String get dealerApproveTitle;

  /// Explains the consequence of the role choice.
  ///
  /// In en, this message translates to:
  /// **'{name} will see the prices for the role you pick, and nothing else.'**
  String dealerApproveBody(String name);

  /// Title of the reject dialog.
  ///
  /// In en, this message translates to:
  /// **'Reject {name}?'**
  String dealerRejectTitle(String name);

  /// Body of the reject dialog.
  ///
  /// In en, this message translates to:
  /// **'They will see the reason you give here when they next open the app.'**
  String get dealerRejectBody;

  /// Field label for the rejection reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get dealerRejectReason;

  /// Placeholder for the rejection reason.
  ///
  /// In en, this message translates to:
  /// **'For example: firm details could not be verified'**
  String get dealerRejectReasonHint;

  /// Title of the suspend dialog.
  ///
  /// In en, this message translates to:
  /// **'Suspend {name}?'**
  String dealerSuspendTitle(String name);

  /// Body of the suspend dialog.
  ///
  /// In en, this message translates to:
  /// **'They lose catalogue access immediately, including on any device they are already signed in to.'**
  String get dealerSuspendBody;

  /// Title of the reactivate dialog.
  ///
  /// In en, this message translates to:
  /// **'Reactivate {name}?'**
  String dealerReactivateTitle(String name);

  /// Body of the reactivate dialog.
  ///
  /// In en, this message translates to:
  /// **'Catalogue access is restored at the role they held before.'**
  String get dealerReactivateBody;

  /// Snackbar after approving.
  ///
  /// In en, this message translates to:
  /// **'{name} approved'**
  String dealerApproved(String name);

  /// Snackbar after rejecting.
  ///
  /// In en, this message translates to:
  /// **'{name} rejected'**
  String dealerRejectedToast(String name);

  /// Snackbar after suspending.
  ///
  /// In en, this message translates to:
  /// **'{name} suspended'**
  String dealerSuspendedToast(String name);

  /// Snackbar after reactivating.
  ///
  /// In en, this message translates to:
  /// **'{name} reactivated'**
  String dealerReactivatedToast(String name);

  /// Label for the dealer GST number.
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get dealerGstLabel;

  /// Shown when a dealer left GST blank.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get dealerNoGst;

  /// App bar title on the More tab.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// Section header on the More tab.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get moreAccount;

  /// Section header on the More tab.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get moreTools;

  /// Section header on the More tab.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get moreAbout;

  /// App version row.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String moreVersion(String version);

  /// App bar title on the approval queue.
  ///
  /// In en, this message translates to:
  /// **'Approval requests'**
  String get requestsTitle;

  /// Count line above the queue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing waiting} =1{1 dealer waiting on you} other{{count} dealers waiting on you}}'**
  String requestsSubtitle(num count);

  /// Empty state headline for the queue.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting'**
  String get requestsEmptyTitle;

  /// Empty state body.
  ///
  /// In en, this message translates to:
  /// **'New dealer registrations will appear here for your decision.'**
  String get requestsEmptyBody;

  /// Time since the request was made.
  ///
  /// In en, this message translates to:
  /// **'Requested {age}'**
  String requestsTimeAgo(String age);

  /// Dials the dealer.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get actionCall;

  /// Opens a WhatsApp chat with the dealer.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get actionWhatsApp;

  /// Label above the role the dealer selected at signup.
  ///
  /// In en, this message translates to:
  /// **'Asked for'**
  String get requestedRole;

  /// Approval confirmation sheet title.
  ///
  /// In en, this message translates to:
  /// **'Approve {firm}'**
  String approveSheetTitle(String firm);

  /// Explains the role choice.
  ///
  /// In en, this message translates to:
  /// **'They asked to be a {role}. Confirm that, or change it - the role decides which price list they see.'**
  String approveSheetBody(String role);

  /// Caution shown when the dealer self-selected wholesaler.
  ///
  /// In en, this message translates to:
  /// **'They picked this themselves. Check it is right before approving.'**
  String get approveSheetWarning;

  /// Confirm button on the approval sheet.
  ///
  /// In en, this message translates to:
  /// **'Approve as {role}'**
  String approveSheetConfirm(String role);

  /// Rejection sheet title.
  ///
  /// In en, this message translates to:
  /// **'Reject {firm}'**
  String rejectSheetTitle(String firm);

  /// Rejection sheet body.
  ///
  /// In en, this message translates to:
  /// **'Choose a reason. The dealer sees this, so keep it plain.'**
  String get rejectSheetBody;

  /// Preset rejection reason.
  ///
  /// In en, this message translates to:
  /// **'Not a registered business'**
  String get rejectReasonNotBusiness;

  /// Preset rejection reason.
  ///
  /// In en, this message translates to:
  /// **'Duplicate account'**
  String get rejectReasonDuplicate;

  /// Preset rejection reason.
  ///
  /// In en, this message translates to:
  /// **'Outside service area'**
  String get rejectReasonOutsideArea;

  /// Preset rejection reason.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get rejectReasonOther;

  /// Label for the optional free-text note.
  ///
  /// In en, this message translates to:
  /// **'Anything to add'**
  String get rejectNotesLabel;

  /// Placeholder for the note field.
  ///
  /// In en, this message translates to:
  /// **'Optional detail for the dealer'**
  String get rejectNotesHint;

  /// Shown when reject is tapped with no reason selected.
  ///
  /// In en, this message translates to:
  /// **'Choose a reason first'**
  String get rejectPickReason;

  /// Shown when Other is chosen with no note.
  ///
  /// In en, this message translates to:
  /// **'Describe the reason'**
  String get rejectNeedsNote;

  /// Confirm button on the rejection sheet.
  ///
  /// In en, this message translates to:
  /// **'Reject dealer'**
  String get actionConfirmReject;

  /// Segmented control option.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get directorySegmentAll;

  /// Segmented control option.
  ///
  /// In en, this message translates to:
  /// **'Wholesalers'**
  String get directorySegmentWholesalers;

  /// Segmented control option.
  ///
  /// In en, this message translates to:
  /// **'Retailers'**
  String get directorySegmentRetailers;

  /// Segmented control option.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get directorySegmentSuspended;

  /// Search field placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search firm, name, phone or city'**
  String get directorySearchHint;

  /// Empty state headline.
  ///
  /// In en, this message translates to:
  /// **'No dealers here yet'**
  String get directoryEmptyTitle;

  /// Empty state body.
  ///
  /// In en, this message translates to:
  /// **'Approved dealers appear in this list.'**
  String get directoryEmptyBody;

  /// Empty state when a search returns nothing.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get directoryNoResultsTitle;

  /// Empty search body.
  ///
  /// In en, this message translates to:
  /// **'Try a different firm name, phone number or city.'**
  String get directoryNoResultsBody;

  /// Banner linking to the queue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dealer is waiting for approval} other{{count} dealers are waiting for approval}}'**
  String directoryPendingBanner(num count);

  /// App bar title on the dealer detail screen.
  ///
  /// In en, this message translates to:
  /// **'Dealer'**
  String get dealerDetailTitle;

  /// Label for the approval date.
  ///
  /// In en, this message translates to:
  /// **'Approved on'**
  String get dealerApprovedOn;

  /// Label for who approved.
  ///
  /// In en, this message translates to:
  /// **'Approved by'**
  String get dealerApprovedBy;

  /// Shown when the current owner approved the dealer.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get dealerApprovedByYou;

  /// Label for the signup date.
  ///
  /// In en, this message translates to:
  /// **'Registered on'**
  String get dealerRegisteredOn;

  /// Label for lifetime scan count.
  ///
  /// In en, this message translates to:
  /// **'Total scans'**
  String get dealerTotalScans;

  /// Label for the most recent scan.
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get dealerLastActive;

  /// Shown when a dealer has no scans at all.
  ///
  /// In en, this message translates to:
  /// **'Never used the app'**
  String get dealerNeverActive;

  /// Label for the dealer address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get dealerAddressLabel;

  /// Shown when an optional field is blank.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get dealerNoAddress;

  /// Action on the dealer detail screen.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get dealerChangeRole;

  /// Role change sheet title.
  ///
  /// In en, this message translates to:
  /// **'Change role for {firm}'**
  String dealerChangeRoleTitle(String firm);

  /// Role change sheet body.
  ///
  /// In en, this message translates to:
  /// **'This changes which price list they see from their next sign-in.'**
  String get dealerChangeRoleBody;

  /// Snackbar after a role change.
  ///
  /// In en, this message translates to:
  /// **'{firm} is now a {role}'**
  String dealerRoleChanged(String firm, String role);

  /// Action that emails a reset link.
  ///
  /// In en, this message translates to:
  /// **'Send password reset'**
  String get dealerResetPassword;

  /// Confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Send a reset link?'**
  String get dealerResetPasswordTitle;

  /// Confirmation body.
  ///
  /// In en, this message translates to:
  /// **'{firm} will get an email with a link to set a new password. You will not see the password.'**
  String dealerResetPasswordBody(String firm);

  /// Snackbar after sending a reset email.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent'**
  String get dealerResetPasswordSent;

  /// App bar title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Section header above the pending card.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get dashboardNeedsAttention;

  /// Pending approvals card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dealer waiting} other{{count} dealers waiting}}'**
  String dashboardPendingCta(num count);

  /// Pending card when the queue is empty.
  ///
  /// In en, this message translates to:
  /// **'No requests waiting'**
  String get dashboardPendingClear;

  /// Section header above the product counts.
  ///
  /// In en, this message translates to:
  /// **'Catalogue'**
  String get dashboardCatalogue;

  /// Section header above the dealer counts.
  ///
  /// In en, this message translates to:
  /// **'Dealer network'**
  String get dashboardNetwork;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Most scanned, last 30 days'**
  String get dashboardTopScanned;

  /// Empty state for the scan table.
  ///
  /// In en, this message translates to:
  /// **'No scans recorded yet. Counts appear once dealers start scanning.'**
  String get dashboardTopScannedEmpty;

  /// Scan count beside a product.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scan} other{{count} scans}}'**
  String dashboardScanCount(num count);

  /// Section header above the horizontal product strip.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get dashboardRecentlyAdded;

  /// Section header above the audit feed.
  ///
  /// In en, this message translates to:
  /// **'Recent dealer activity'**
  String get dashboardActivity;

  /// Empty state for the activity feed.
  ///
  /// In en, this message translates to:
  /// **'No dealer decisions yet.'**
  String get dashboardActivityEmpty;

  /// Inline error inside one dashboard card.
  ///
  /// In en, this message translates to:
  /// **'Could not load this'**
  String get dashboardCardFailed;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statActiveProducts;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Wholesalers'**
  String get statWholesalers;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Retailers'**
  String get statRetailers;

  /// Stat tile label.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statSuspended;

  /// Quick action on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'View requests'**
  String get actionViewRequests;

  /// Audit feed line.
  ///
  /// In en, this message translates to:
  /// **'{firm} approved'**
  String activityApproved(String firm);

  /// Audit feed line.
  ///
  /// In en, this message translates to:
  /// **'{firm} rejected'**
  String activityRejected(String firm);

  /// Audit feed line.
  ///
  /// In en, this message translates to:
  /// **'{firm} suspended'**
  String activitySuspended(String firm);

  /// Audit feed line.
  ///
  /// In en, this message translates to:
  /// **'{firm} reactivated'**
  String activityReactivated(String firm);

  /// Audit feed line.
  ///
  /// In en, this message translates to:
  /// **'{firm} role changed'**
  String activityRoleChanged(String firm);

  /// Relative timestamp.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// Relative timestamp.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String timeMinutes(num count);

  /// Relative timestamp.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String timeHours(num count);

  /// Relative timestamp.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{yesterday} other{{count} days ago}}'**
  String timeDays(num count);

  /// Row opening the owner profile screen.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get moreProfile;

  /// Row opening the password screen.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get moreChangePassword;

  /// Row opening the label footer settings.
  ///
  /// In en, this message translates to:
  /// **'Business details'**
  String get moreBusinessDetails;

  /// Subtitle under the business details row.
  ///
  /// In en, this message translates to:
  /// **'Printed on labels and exports'**
  String get moreBusinessDetailsHelp;

  /// Row opening the language picker.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get moreLanguage;

  /// Language option that follows the phone.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get moreLanguageSystem;

  /// Row that exports the owner price list.
  ///
  /// In en, this message translates to:
  /// **'Export catalogue (PDF)'**
  String get moreExportCatalogue;

  /// Subtitle warning about the owner export.
  ///
  /// In en, this message translates to:
  /// **'Both price columns. Do not share with dealers.'**
  String get moreExportCatalogueHelp;

  /// Row that exports the dealer list.
  ///
  /// In en, this message translates to:
  /// **'Export dealer list (CSV)'**
  String get moreExportDealers;

  /// Support row.
  ///
  /// In en, this message translates to:
  /// **'Contact Krishna AI Links'**
  String get moreSupport;

  /// Subtitle under the support row.
  ///
  /// In en, this message translates to:
  /// **'App support and changes'**
  String get moreSupportHelp;

  /// Shown when an export would be empty.
  ///
  /// In en, this message translates to:
  /// **'There is nothing to export yet.'**
  String get moreExportEmpty;

  /// Shown when an export fails.
  ///
  /// In en, this message translates to:
  /// **'The export could not be created.'**
  String get moreExportFailed;

  /// App bar title.
  ///
  /// In en, this message translates to:
  /// **'Business details'**
  String get businessTitle;

  /// Explanatory paragraph.
  ///
  /// In en, this message translates to:
  /// **'These appear on every printed label and on the catalogue export. Changing them here updates the next thing you print.'**
  String get businessIntro;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessNameLabel;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get businessPhoneLabel;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get businessAddressLabel;

  /// Snackbar after saving.
  ///
  /// In en, this message translates to:
  /// **'Business details saved'**
  String get businessSaved;

  /// Header above the live label preview.
  ///
  /// In en, this message translates to:
  /// **'Label preview'**
  String get businessPreview;

  /// App bar title.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileTitle;

  /// App bar title.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordTitle;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNewLabel;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get passwordConfirmLabel;

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'The two passwords do not match'**
  String get passwordMismatch;

  /// Snackbar after a successful change.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// Language picker title.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageTitle;

  /// Language option.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option, always shown in Gujarati.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get languageGujarati;

  /// Shown when the owner suspended the account mid-session.
  ///
  /// In en, this message translates to:
  /// **'Your account is no longer active'**
  String get errorRevokedTitle;

  /// Body for the revoked-session error.
  ///
  /// In en, this message translates to:
  /// **'Maruti Water Solution has paused your access. Contact them to restore it.'**
  String get errorRevokedBody;

  /// Bottom navigation label.
  ///
  /// In en, this message translates to:
  /// **'Catalogue'**
  String get navCatalogue;

  /// Bottom navigation label.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// Bottom navigation label.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// Bottom navigation label.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// App bar title.
  ///
  /// In en, this message translates to:
  /// **'Catalogue'**
  String get catalogueTitle;

  /// Search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name, model or code'**
  String get catalogueSearchHint;

  /// Empty state headline.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the catalogue yet'**
  String get catalogueEmptyTitle;

  /// Empty state body.
  ///
  /// In en, this message translates to:
  /// **'Products added by Maruti Water Solution will appear here.'**
  String get catalogueEmptyBody;

  /// Empty search headline.
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get catalogueNoResultsTitle;

  /// Empty search body.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, model number or category.'**
  String get catalogueNoResultsBody;

  /// The single price label shown to a wholesaler.
  ///
  /// In en, this message translates to:
  /// **'Wholesale price'**
  String get labelWholesalePrice;

  /// The single price label shown to a retailer.
  ///
  /// In en, this message translates to:
  /// **'Retail price'**
  String get labelRetailPrice;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get catalogueSortName;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get catalogueSortPriceLow;

  /// Sort option.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get catalogueSortPriceHigh;

  /// Sort sheet title.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get catalogueSortLabel;

  /// Row count above the grid.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product} other{{count} products}}'**
  String catalogueCountLabel(num count);

  /// Offline banner headline.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved catalogue'**
  String get offlineBannerTitle;

  /// Offline banner age line.
  ///
  /// In en, this message translates to:
  /// **'Last updated {age}'**
  String offlineBannerUpdated(String age);

  /// Shown when the cache is older than the lifetime.
  ///
  /// In en, this message translates to:
  /// **'Saved catalogue is out of date'**
  String get offlineExpiredTitle;

  /// Body for the expired cache state.
  ///
  /// In en, this message translates to:
  /// **'This catalogue is more than 7 days old, so prices may have changed. Connect to the internet to refresh it.'**
  String get offlineExpiredBody;

  /// Shown while a silent refresh runs.
  ///
  /// In en, this message translates to:
  /// **'Refreshing in the background'**
  String get offlineRefreshing;

  /// Scanner screen title.
  ///
  /// In en, this message translates to:
  /// **'Scan a product'**
  String get scanTitle;

  /// Instruction under the scan window.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the barcode or QR code on the label'**
  String get scanHint;

  /// Torch button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn on the light'**
  String get scanTorchOn;

  /// Torch button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn off the light'**
  String get scanTorchOff;

  /// Camera flip tooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get scanFlipCamera;

  /// Opens the manual entry sheet.
  ///
  /// In en, this message translates to:
  /// **'Enter code manually'**
  String get scanManualEntry;

  /// Manual entry sheet title.
  ///
  /// In en, this message translates to:
  /// **'Enter the product code'**
  String get scanManualTitle;

  /// Placeholder showing the code shape.
  ///
  /// In en, this message translates to:
  /// **'MWS-DOM-001042-Z'**
  String get scanManualHint;

  /// Helper text on the manual entry field.
  ///
  /// In en, this message translates to:
  /// **'The code is printed under the barcode on the label.'**
  String get scanManualHelp;

  /// Shown for a code that fails the format or check character.
  ///
  /// In en, this message translates to:
  /// **'Invalid code.'**
  String get scanInvalidCode;

  /// Shown for a well-formed code with no product.
  ///
  /// In en, this message translates to:
  /// **'That code is valid but no product matches it'**
  String get scanUnknownCode;

  /// Shown when the lookup itself failed.
  ///
  /// In en, this message translates to:
  /// **'Could not look that up. Check your connection.'**
  String get scanLookupFailed;

  /// Permission prompt title.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to scan'**
  String get scanPermissionTitle;

  /// Permission prompt body.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access so the app can read barcodes on your product labels.'**
  String get scanPermissionBody;

  /// Body when permission is permanently denied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is turned off for this app. Turn it on in Settings to scan.'**
  String get scanPermissionDeniedBody;

  /// Shown when mobile_scanner reports a generic failure.
  ///
  /// In en, this message translates to:
  /// **'The camera could not be started'**
  String get scanCameraFailed;

  /// Shown while a lookup is in flight.
  ///
  /// In en, this message translates to:
  /// **'Looking up the code'**
  String get scanSearching;

  /// Detail screen title.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productDetailTitle;

  /// Gallery empty state.
  ///
  /// In en, this message translates to:
  /// **'No photos for this product'**
  String get productNoImages;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get productSpecifications;

  /// Shown when the jsonb is empty.
  ///
  /// In en, this message translates to:
  /// **'No specifications listed'**
  String get productNoSpecifications;

  /// Warranty badge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month warranty} other{{count} months warranty}}'**
  String productWarranty(num count);

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription;

  /// Shown when the product is already saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get actionSaved;

  /// Snackbar after saving.
  ///
  /// In en, this message translates to:
  /// **'{name} saved'**
  String productSavedToast(String name);

  /// Snackbar after unsaving.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from saved'**
  String productUnsavedToast(String name);

  /// Opens WhatsApp to the client's number.
  ///
  /// In en, this message translates to:
  /// **'Enquire'**
  String get actionEnquire;

  /// Shown when sharing fails.
  ///
  /// In en, this message translates to:
  /// **'Could not open the share sheet'**
  String get productShareFailed;

  /// Hint on the full-screen image viewer.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom'**
  String get productZoomHint;

  /// First line of the shared WhatsApp message.
  ///
  /// In en, this message translates to:
  /// **'{business} — product details'**
  String shareHeading(String business);

  /// Label inside the shared message.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get shareCodeLabel;

  /// Label inside the shared message.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sharePriceLabel;

  /// Pre-filled enquiry message.
  ///
  /// In en, this message translates to:
  /// **'Hello, I would like to enquire about {name} ({code}).'**
  String shareEnquiry(String name, String code);

  /// Saved tab title.
  ///
  /// In en, this message translates to:
  /// **'Saved products'**
  String get savedTitle;

  /// Search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search saved products'**
  String get savedSearchHint;

  /// Empty state headline.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedEmptyTitle;

  /// Empty state body.
  ///
  /// In en, this message translates to:
  /// **'Save a product from the catalogue and it will appear here, ready to quote.'**
  String get savedEmptyBody;

  /// Removes a product from the saved list.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get savedRemove;

  /// Builds the quotation sheet.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get savedExportPdf;

  /// Shown when PDF generation fails.
  ///
  /// In en, this message translates to:
  /// **'The quotation could not be created'**
  String get savedExportFailed;

  /// Count above the saved list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved product} other{{count} saved products}}'**
  String savedCount(num count);

  /// Heading on the generated PDF.
  ///
  /// In en, this message translates to:
  /// **'Quotation'**
  String get quotationTitle;

  /// Account tab title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// Section header on the account tab.
  ///
  /// In en, this message translates to:
  /// **'Offline catalogue'**
  String get accountCacheSection;

  /// Cache status line.
  ///
  /// In en, this message translates to:
  /// **'{count} products saved on this phone, {size}'**
  String accountCacheStatus(int count, String size);

  /// Cache status when the cache is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved for offline use yet'**
  String get accountCacheEmpty;

  /// When the cache was last refreshed.
  ///
  /// In en, this message translates to:
  /// **'Updated {age}'**
  String accountCacheUpdated(String age);

  /// Action that empties the cache.
  ///
  /// In en, this message translates to:
  /// **'Clear offline catalogue'**
  String get accountClearCache;

  /// Confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Clear the offline catalogue?'**
  String get accountClearCacheTitle;

  /// Confirmation body.
  ///
  /// In en, this message translates to:
  /// **'The catalogue will be downloaded again next time you have signal. Your saved products are kept.'**
  String get accountClearCacheBody;

  /// Snackbar after clearing.
  ///
  /// In en, this message translates to:
  /// **'Offline catalogue cleared'**
  String get accountCacheCleared;

  /// Dismisses the full-screen image viewer.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Button that re-asks for camera permission after a soft denial.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access'**
  String get scanPermissionAllow;

  /// Empty state when a search over the saved list returns nothing.
  ///
  /// In en, this message translates to:
  /// **'No matching saved products'**
  String get savedNoResultsTitle;

  /// Body for the empty saved-search state.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, model number or code.'**
  String get savedNoResultsBody;

  /// Label on the manual code entry field.
  ///
  /// In en, this message translates to:
  /// **'Product code'**
  String get scanManualFieldLabel;

  /// Title for complaints section
  ///
  /// In en, this message translates to:
  /// **'Complaints & Support'**
  String get complaintsTitle;

  /// Subtitle for complaints section
  ///
  /// In en, this message translates to:
  /// **'Track and submit issues or service requests'**
  String get complaintsSubtitle;

  /// Button to open complaint creation form
  ///
  /// In en, this message translates to:
  /// **'New Complaint'**
  String get complaintNewButton;

  /// Form label for complaint subject
  ///
  /// In en, this message translates to:
  /// **'Subject / Title'**
  String get complaintFieldSubject;

  /// Form label for complaint category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get complaintFieldCategory;

  /// Form label for related product
  ///
  /// In en, this message translates to:
  /// **'Related Product (Optional)'**
  String get complaintFieldProduct;

  /// Form label for order reference
  ///
  /// In en, this message translates to:
  /// **'Order / Invoice Reference (Optional)'**
  String get complaintFieldReference;

  /// Form label for complaint priority
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get complaintFieldPriority;

  /// Form label for complaint description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get complaintFieldDescription;

  /// Form section for attachments
  ///
  /// In en, this message translates to:
  /// **'Attachments / Photos'**
  String get complaintFieldAttachments;

  /// Button to pick photo attachment
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get complaintAddPhoto;

  /// Button to submit complaint
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get complaintSubmitButton;

  /// Dialog title after submission
  ///
  /// In en, this message translates to:
  /// **'Complaint Submitted'**
  String get complaintSubmittedTitle;

  /// Confirmation message after complaint submission.
  ///
  /// In en, this message translates to:
  /// **'Your complaint has been logged under ticket number {ticketNumber}.'**
  String complaintSubmittedBody(String ticketNumber);

  /// Empty state title for user complaints list
  ///
  /// In en, this message translates to:
  /// **'No Complaints Found'**
  String get complaintEmptyTitle;

  /// Empty state body for user complaints list
  ///
  /// In en, this message translates to:
  /// **'You have not submitted any complaints yet.'**
  String get complaintEmptyBody;

  /// Category enum option
  ///
  /// In en, this message translates to:
  /// **'Product Issue'**
  String get complaintCategoryProductIssue;

  /// Category enum option
  ///
  /// In en, this message translates to:
  /// **'Installation Issue'**
  String get complaintCategoryInstallationIssue;

  /// Category enum option
  ///
  /// In en, this message translates to:
  /// **'Warranty Issue'**
  String get complaintCategoryWarrantyIssue;

  /// Category enum option
  ///
  /// In en, this message translates to:
  /// **'Delivery Issue'**
  String get complaintCategoryDeliveryIssue;

  /// Category enum option
  ///
  /// In en, this message translates to:
  /// **'Billing Issue'**
  String get complaintCategoryBillingIssue;

  /// Category enum option
  ///
  /// In en, this message translates to:
  /// **'Technical Issue'**
  String get complaintCategoryTechnicalIssue;

  /// Category enum option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get complaintCategoryOther;

  /// Priority enum option
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get complaintPriorityLow;

  /// Priority enum option
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get complaintPriorityMedium;

  /// Priority enum option
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get complaintPriorityHigh;

  /// Priority enum option
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get complaintPriorityUrgent;

  /// Status enum option
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get complaintStatusOpen;

  /// Status enum option
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get complaintStatusInProgress;

  /// Status enum option
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get complaintStatusResolved;

  /// Status enum option
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get complaintStatusClosed;

  /// Header for messages timeline
  ///
  /// In en, this message translates to:
  /// **'Updates & Messages'**
  String get complaintMessagesHeader;

  /// Placeholder for reply input
  ///
  /// In en, this message translates to:
  /// **'Type a message or response...'**
  String get complaintAddMessageHint;

  /// Send button for messages
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get complaintSendButton;

  /// Checkbox label for internal note
  ///
  /// In en, this message translates to:
  /// **'Internal Admin Note (Owner only)'**
  String get complaintInternalNoteLabel;

  /// Owner title for complaints section
  ///
  /// In en, this message translates to:
  /// **'Complaint Management'**
  String get ownerComplaintsTitle;

  /// Owner subtitle for complaints section
  ///
  /// In en, this message translates to:
  /// **'Manage dealer service tickets and responses'**
  String get ownerComplaintsSubtitle;

  /// No description provided for @unitDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Unit Details'**
  String get unitDetailsTitle;

  /// No description provided for @unitNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Unit Not Found'**
  String get unitNotFoundTitle;

  /// No description provided for @unitNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'That unit serial code was not found in Maruti Water Solution database.'**
  String get unitNotFoundBody;

  /// No description provided for @unitActionRaiseComplaint.
  ///
  /// In en, this message translates to:
  /// **'Raise Service Complaint'**
  String get unitActionRaiseComplaint;

  /// No description provided for @unitSectionMachineTitle.
  ///
  /// In en, this message translates to:
  /// **'Machine Information'**
  String get unitSectionMachineTitle;

  /// No description provided for @unitLabelSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get unitLabelSerialNumber;

  /// No description provided for @unitLabelManufacturedAt.
  ///
  /// In en, this message translates to:
  /// **'Manufactured Date'**
  String get unitLabelManufacturedAt;

  /// No description provided for @unitSerialCopied.
  ///
  /// In en, this message translates to:
  /// **'Serial number copied to clipboard'**
  String get unitSerialCopied;

  /// No description provided for @unitSectionWarrantyTitle.
  ///
  /// In en, this message translates to:
  /// **'Warranty Status'**
  String get unitSectionWarrantyTitle;

  /// No description provided for @warrantyStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get warrantyStatusActive;

  /// No description provided for @warrantyStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get warrantyStatusExpired;

  /// No description provided for @warrantyStatusUnactivated.
  ///
  /// In en, this message translates to:
  /// **'Standard Warranty'**
  String get warrantyStatusUnactivated;

  /// No description provided for @warrantyLabelStandardCoverage.
  ///
  /// In en, this message translates to:
  /// **'Standard Coverage'**
  String get warrantyLabelStandardCoverage;

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get unitMonths;

  /// No description provided for @warrantyLabelCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get warrantyLabelCustomerName;

  /// No description provided for @warrantyLabelCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer Phone'**
  String get warrantyLabelCustomerPhone;

  /// No description provided for @warrantyLabelInstallationDate.
  ///
  /// In en, this message translates to:
  /// **'Installation Date'**
  String get warrantyLabelInstallationDate;

  /// No description provided for @warrantyLabelEndDate.
  ///
  /// In en, this message translates to:
  /// **'Warranty Expiry Date'**
  String get warrantyLabelEndDate;

  /// No description provided for @warrantyLabelInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get warrantyLabelInvoiceNumber;

  /// No description provided for @warrantyUnactivatedHelp.
  ///
  /// In en, this message translates to:
  /// **'Standard factory warranty applies. Warranty registration will be activated upon unit installation.'**
  String get warrantyUnactivatedHelp;

  /// No description provided for @manageBannersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Banners'**
  String get manageBannersTitle;

  /// No description provided for @manageBannersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage home dashboard promotional carousel banners'**
  String get manageBannersSubtitle;

  /// No description provided for @actionAddBanner.
  ///
  /// In en, this message translates to:
  /// **'Add Banner'**
  String get actionAddBanner;

  /// No description provided for @bannerStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get bannerStatusActive;

  /// No description provided for @bannerStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get bannerStatusInactive;

  /// No description provided for @bannerActionReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace Image'**
  String get bannerActionReplace;

  /// No description provided for @bannerActionMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move Up'**
  String get bannerActionMoveUp;

  /// No description provided for @bannerActionMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move Down'**
  String get bannerActionMoveDown;

  /// No description provided for @bannerActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Banner'**
  String get bannerActionDelete;

  /// No description provided for @bannerDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Banner?'**
  String get bannerDeleteConfirmTitle;

  /// No description provided for @bannerDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this banner? This action cannot be undone.'**
  String get bannerDeleteConfirmBody;

  /// No description provided for @bannerRecommendedHint.
  ///
  /// In en, this message translates to:
  /// **'Recommended format: 16:7 aspect ratio wide banner image.'**
  String get bannerRecommendedHint;

  /// No description provided for @bannerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Banners Added'**
  String get bannerEmptyTitle;

  /// No description provided for @bannerEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Banner to upload promotional slider images for the user dashboard.'**
  String get bannerEmptyBody;

  /// No description provided for @bannerUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Banner uploaded successfully'**
  String get bannerUploadSuccess;

  /// No description provided for @bannerDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Banner deleted successfully'**
  String get bannerDeleteSuccess;

  /// No description provided for @scanOptionRegisterProduct.
  ///
  /// In en, this message translates to:
  /// **'Register Product'**
  String get scanOptionRegisterProduct;

  /// No description provided for @scanOptionClaimWarranty.
  ///
  /// In en, this message translates to:
  /// **'Claim / Warranty'**
  String get scanOptionClaimWarranty;

  /// No description provided for @scanOptionScanCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Code'**
  String get scanOptionScanCode;

  /// No description provided for @scanFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Scan from Gallery'**
  String get scanFromGallery;

  /// No description provided for @scanNoQrFound.
  ///
  /// In en, this message translates to:
  /// **'No QR code found in this image.'**
  String get scanNoQrFound;

  /// No description provided for @scanMultipleQrFound.
  ///
  /// In en, this message translates to:
  /// **'Multiple QR codes found. Please select an image containing one QR code.'**
  String get scanMultipleQrFound;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'gu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'gu': return AppLocalizationsGu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
