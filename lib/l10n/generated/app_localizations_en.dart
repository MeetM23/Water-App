import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Maruti Water';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionContinue => 'Continue';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorGenericBody => 'We could not complete that just now. Please try again.';

  @override
  String get errorNetworkTitle => 'No internet connection';

  @override
  String get errorNetworkBody => 'Check your mobile data or Wi-Fi, then try again.';

  @override
  String get errorServerTitle => 'Maruti Water is not responding';

  @override
  String get errorServerBody => 'The service is temporarily unavailable. Please try again in a moment.';

  @override
  String get errorRateLimitedTitle => 'Too many attempts';

  @override
  String get errorRateLimitedBody => 'Please wait a few minutes before trying again.';

  @override
  String get errorSessionExpiredTitle => 'You have been signed out';

  @override
  String get errorSessionExpiredBody => 'Your session expired. Please sign in again.';

  @override
  String validationRequired(String field) {
    return '$field is required';
  }

  @override
  String get validationEmail => 'Enter a valid email address';

  @override
  String get validationPhone => 'Enter a 10-digit mobile number';

  @override
  String get validationPassword => 'Use at least 8 characters';

  @override
  String get validationGst => 'Enter a valid 15-character GST number';

  @override
  String validationTooShort(int count) {
    return 'Enter at least $count characters';
  }

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Maruti Water Solution dealer portal';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginNoAccount => 'New dealer?';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get loginFailed => 'Email or password is incorrect.';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get signupSubtitle => 'Maruti Water Solution reviews every new dealer before the account is activated.';

  @override
  String get signupSubmit => 'Create account';

  @override
  String get signupHaveAccount => 'Already registered?';

  @override
  String get signupSignIn => 'Sign in';

  @override
  String get signupEmailTaken => 'An account already exists for this email address.';

  @override
  String get signupAccountType => 'Account type';

  @override
  String get signupSectionAccount => 'Account';

  @override
  String get signupSectionBusiness => 'Business details';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldFirmName => 'Firm name';

  @override
  String get fieldPhone => 'Phone number';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldState => 'State';

  @override
  String get fieldGstNumber => 'GST number';

  @override
  String get fieldOptional => 'Optional';

  @override
  String get hintPhone => '10-digit mobile number';

  @override
  String get hintGstNumber => '24ABCDE1234F1Z5';

  @override
  String get roleWholesaler => 'Wholesaler';

  @override
  String get roleWholesalerHelp => 'You will see wholesale pricing';

  @override
  String get roleRetailer => 'Retailer';

  @override
  String get roleRetailerHelp => 'You will see retail pricing';

  @override
  String get pendingTitle => 'Waiting for approval';

  @override
  String get pendingBody => 'Maruti Water Solution checks every new dealer account by hand. You will be able to sign in as soon as yours is approved.';

  @override
  String get pendingFirmLabel => 'Registered firm';

  @override
  String get pendingCheckStatus => 'Check status';

  @override
  String get pendingStillWaiting => 'Your account is still awaiting approval.';

  @override
  String get rejectedTitle => 'Account not approved';

  @override
  String get rejectedBody => 'Maruti Water Solution did not approve this account.';

  @override
  String get rejectedReasonLabel => 'Reason given';

  @override
  String get rejectedNoReason => 'No reason was recorded.';

  @override
  String get suspendedTitle => 'Account suspended';

  @override
  String get suspendedBody => 'Access to this account has been paused by Maruti Water Solution. Get in touch to have it restored.';

  @override
  String get contactWhatsApp => 'Contact us on WhatsApp';

  @override
  String get contactUnavailable => 'WhatsApp could not be opened on this device.';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmBody => 'You will need your email and password to sign in again.';

  @override
  String get emptyDefaultTitle => 'Nothing here yet';

  @override
  String get emptyDefaultBody => 'Once there is something to show, it will appear here.';

  @override
  String get actionShow => 'Show';

  @override
  String get actionHide => 'Hide';

  @override
  String get actionClear => 'Clear';

  @override
  String get homeTitle => 'Account';

  @override
  String get homeSignedInTitle => 'You are signed in';

  @override
  String get homeSignedInBody => 'Your account is approved. The catalogue arrives in the next release.';

  @override
  String get labelRole => 'Role';

  @override
  String get labelStatus => 'Status';

  @override
  String get labelFirm => 'Firm';

  @override
  String get labelPhone => 'Phone';

  @override
  String get labelCity => 'City';

  @override
  String get roleOwner => 'Owner';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get hintEmail => 'name@example.com';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProducts => 'Products';

  @override
  String get navDealers => 'Dealers';

  @override
  String get navMore => 'More';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionShare => 'Share';

  @override
  String get actionPrint => 'Print';

  @override
  String get actionDone => 'Done';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionViewAll => 'View all';

  @override
  String get statTotalProducts => 'Products';

  @override
  String get statOutOfStock => 'Out of stock';

  @override
  String get statInactive => 'Inactive';

  @override
  String get statPendingDealers => 'Pending dealers';

  @override
  String get dashboardQuickActions => 'Quick actions';

  @override
  String get dashboardRecentProducts => 'Recently added';

  @override
  String get actionAddProduct => 'Add product';

  @override
  String get actionPrintLabels => 'Print labels';

  @override
  String get actionReviewDealers => 'Review dealers';

  @override
  String get productsTitle => 'Products';

  @override
  String get searchProductsHint => 'Search name, model or code';

  @override
  String get filterTitle => 'Filter and sort';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterStatus => 'Availability';

  @override
  String get filterSort => 'Sort by';

  @override
  String get categoryAll => 'All categories';

  @override
  String get categoryDomestic => 'Domestic';

  @override
  String get categoryCommercial => 'Commercial';

  @override
  String get categoryIndustrial => 'Industrial';

  @override
  String get categorySparePart => 'Spare part';

  @override
  String get categoryAccessory => 'Accessory';

  @override
  String get statusAll => 'All';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactiveFilter => 'Inactive';

  @override
  String get statusOutOfStockFilter => 'Out of stock';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortName => 'Name';

  @override
  String get sortPriceLowHigh => 'Price, low to high';

  @override
  String get sortPriceHighLow => 'Price, high to low';

  @override
  String get labelWholesale => 'Wholesale';

  @override
  String get labelRetail => 'Retail';

  @override
  String get labelMrp => 'MRP';

  @override
  String get labelMargin => 'Dealer margin';

  @override
  String get badgeInStock => 'In stock';

  @override
  String get badgeOutOfStock => 'Out of stock';

  @override
  String get badgeInactive => 'Inactive';

  @override
  String get productsEmptyTitle => 'No products yet';

  @override
  String get productsEmptyBody => 'Add your first product and the database will issue its permanent barcode.';

  @override
  String get productsNoResultsTitle => 'Nothing matches that';

  @override
  String get productsNoResultsBody => 'Try a different search term, or clear the filters to see the whole catalogue.';

  @override
  String get productsClearFilters => 'Clear filters';

  @override
  String get quickToggleStock => 'Toggle stock';

  @override
  String get quickToggleActive => 'Toggle active';

  @override
  String get quickDuplicate => 'Duplicate';

  @override
  String get deleteProductTitle => 'Delete product?';

  @override
  String deleteProductBody(String name) {
    return '$name will be removed from the catalogue along with its photos. This cannot be undone.';
  }

  @override
  String productDeleted(String name) {
    return '$name deleted';
  }

  @override
  String productDuplicated(String name) {
    return '$name duplicated';
  }

  @override
  String get productSaved => 'Product saved';

  @override
  String get formNewTitle => 'New product';

  @override
  String get formEditTitle => 'Edit product';

  @override
  String get sectionPhotos => 'Photos';

  @override
  String get sectionBasics => 'Basic details';

  @override
  String get sectionSpecifications => 'Specifications';

  @override
  String get sectionPricing => 'Pricing';

  @override
  String get sectionAvailability => 'Availability';

  @override
  String photosHelp(int count) {
    return 'Up to $count photos. The first is used on the catalogue card.';
  }

  @override
  String get photosAdd => 'Add photo';

  @override
  String get photosPrimary => 'Primary';

  @override
  String get photosSetPrimary => 'Set as primary';

  @override
  String get photosRemoveTitle => 'Remove photo?';

  @override
  String get photosRemoveBody => 'This photo will not be saved with the product.';

  @override
  String photosLimitReached(int count) {
    return 'You can attach up to $count photos.';
  }

  @override
  String get photosUploadFailed => 'That photo could not be uploaded. Tap to try again.';

  @override
  String get photosReorderHint => 'Press and hold a photo to reorder.';

  @override
  String get chooseSourceTitle => 'Add a photo';

  @override
  String get sourceCamera => 'Take a photo';

  @override
  String get sourceGallery => 'Choose from gallery';

  @override
  String get permissionCameraTitle => 'Camera access is off';

  @override
  String get permissionCameraBody => 'Maruti Water needs the camera to photograph a product. You can turn it on in Settings.';

  @override
  String get permissionOpenSettings => 'Open settings';

  @override
  String get permissionSettingsFailed => 'Settings could not be opened on this device.';

  @override
  String get fieldProductName => 'Product name';

  @override
  String get fieldModelNumber => 'Model number';

  @override
  String get fieldCategoryLabel => 'Category';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldCapacity => 'Capacity';

  @override
  String get capacityHelp => 'For example 25 LPH, or 12 L';

  @override
  String get fieldWarrantyMonths => 'Warranty (months)';

  @override
  String get fieldMrpLabel => 'MRP';

  @override
  String get fieldWholesaleLabel => 'Wholesale price';

  @override
  String get fieldRetailLabel => 'Retail price';

  @override
  String get specDetailsLabel => 'Detailed specifications';

  @override
  String get specAddRow => 'Add specification';

  @override
  String get specKeyHint => 'Stages';

  @override
  String get specValueHint => '7';

  @override
  String get specEmpty => 'No specifications yet. Add rows such as Membrane or Body material.';

  @override
  String get fieldInStockLabel => 'In stock';

  @override
  String get fieldInStockHelp => 'Dealers see this product as available to order.';

  @override
  String get fieldActiveLabel => 'Active';

  @override
  String get fieldActiveHelp => 'Inactive products are hidden from every dealer catalogue.';

  @override
  String get priceErrorRetailBelowWholesale => 'Retail price cannot be below the wholesale price';

  @override
  String get priceErrorNotPositive => 'Enter an amount greater than zero';

  @override
  String get priceWarningAboveMrp => 'This price is above the MRP you entered';

  @override
  String get priceWarningZeroMargin => 'Retail equals wholesale, so the dealer earns nothing';

  @override
  String marginChip(String amount, String percent) {
    return '$amount margin ($percent%)';
  }

  @override
  String get marginUnavailable => 'Enter both prices to see the margin';

  @override
  String get unsavedTitle => 'Discard changes?';

  @override
  String get unsavedBody => 'Your edits to this product have not been saved.';

  @override
  String get unsavedDiscard => 'Discard';

  @override
  String get unsavedKeepEditing => 'Keep editing';

  @override
  String get formUploadsInFlight => 'Wait for the photos to finish uploading';

  @override
  String get createdTitle => 'Product created';

  @override
  String get createdBody => 'This code is permanent and is now printed on every label for this product.';

  @override
  String get createdCodeLabel => 'Product code';

  @override
  String get createdCopied => 'Product code copied';

  @override
  String get barcodeCode128 => 'Code 128';

  @override
  String get barcodeQr => 'QR';

  @override
  String detailScanCount(int count) {
    return '$count scans';
  }

  @override
  String get detailSpecifications => 'Specifications';

  @override
  String get detailNoSpecifications => 'No specifications recorded.';

  @override
  String get detailDescription => 'Description';

  @override
  String get detailPricing => 'Pricing';

  @override
  String detailWarranty(int count) {
    return '$count months warranty';
  }

  @override
  String get detailNoImages => 'No photos yet';

  @override
  String get labelsTitle => 'Print labels';

  @override
  String get labelsSelectProducts => 'Select products';

  @override
  String get labelsLayout => 'Sheet layout';

  @override
  String get labelsQuantity => 'Labels per product';

  @override
  String labelsSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String labelsSummary(int labels, int sheets) {
    return '$labels labels across $sheets sheets';
  }

  @override
  String get labelsPreview => 'Preview';

  @override
  String get labelsEmptyTitle => 'Choose products to label';

  @override
  String get labelsEmptyBody => 'Pick one or more products and set how many labels each one needs.';

  @override
  String get labelsNoProductsTitle => 'No products to label';

  @override
  String get labelsNoProductsBody => 'Add a product first and it will appear here ready to print.';

  @override
  String labelsBarcodeTooFine(String width, String minimum) {
    return 'Bars print at $width mm on this stock. Handheld scanners need about $minimum mm, so scan a test label before printing a full run.';
  }

  @override
  String get labelsFilterNotice => 'Showing the products your catalogue filters currently match. Clear them on the Products tab to see everything.';

  @override
  String get labelsGenerateFailed => 'The label sheet could not be generated.';

  @override
  String get dealersTitle => 'Dealers';

  @override
  String get dealersTabPending => 'Pending';

  @override
  String get dealersTabApproved => 'Approved';

  @override
  String get dealersTabRejected => 'Rejected';

  @override
  String get dealersTabSuspended => 'Suspended';

  @override
  String get dealersEmptyPendingTitle => 'No one is waiting';

  @override
  String get dealersEmptyPendingBody => 'New dealer sign-ups will appear here for you to approve or turn down.';

  @override
  String get dealersEmptyTitle => 'Nothing in this list';

  @override
  String get dealersEmptyBody => 'Dealers you move into this state will be listed here.';

  @override
  String get dealerApprove => 'Approve';

  @override
  String get dealerReject => 'Reject';

  @override
  String get dealerSuspend => 'Suspend';

  @override
  String get dealerReactivate => 'Reactivate';

  @override
  String get dealerApproveTitle => 'Approve as which role?';

  @override
  String dealerApproveBody(String name) {
    return '$name will see the prices for the role you pick, and nothing else.';
  }

  @override
  String dealerRejectTitle(String name) {
    return 'Reject $name?';
  }

  @override
  String get dealerRejectBody => 'They will see the reason you give here when they next open the app.';

  @override
  String get dealerRejectReason => 'Reason';

  @override
  String get dealerRejectReasonHint => 'For example: firm details could not be verified';

  @override
  String dealerSuspendTitle(String name) {
    return 'Suspend $name?';
  }

  @override
  String get dealerSuspendBody => 'They lose catalogue access immediately, including on any device they are already signed in to.';

  @override
  String dealerReactivateTitle(String name) {
    return 'Reactivate $name?';
  }

  @override
  String get dealerReactivateBody => 'Catalogue access is restored at the role they held before.';

  @override
  String dealerApproved(String name) {
    return '$name approved';
  }

  @override
  String dealerRejectedToast(String name) {
    return '$name rejected';
  }

  @override
  String dealerSuspendedToast(String name) {
    return '$name suspended';
  }

  @override
  String dealerReactivatedToast(String name) {
    return '$name reactivated';
  }

  @override
  String get dealerGstLabel => 'GST';

  @override
  String get dealerNoGst => 'Not provided';

  @override
  String get moreTitle => 'More';

  @override
  String get moreAccount => 'Account';

  @override
  String get moreTools => 'Tools';

  @override
  String get moreAbout => 'About';

  @override
  String moreVersion(String version) {
    return 'Version $version';
  }

  @override
  String get requestsTitle => 'Approval requests';

  @override
  String requestsSubtitle(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dealers waiting on you',
      one: '1 dealer waiting on you',
      zero: 'Nothing waiting',
    );
    return '$_temp0';
  }

  @override
  String get requestsEmptyTitle => 'Nothing waiting';

  @override
  String get requestsEmptyBody => 'New dealer registrations will appear here for your decision.';

  @override
  String requestsTimeAgo(String age) {
    return 'Requested $age';
  }

  @override
  String get actionCall => 'Call';

  @override
  String get actionWhatsApp => 'WhatsApp';

  @override
  String get requestedRole => 'Asked for';

  @override
  String approveSheetTitle(String firm) {
    return 'Approve $firm';
  }

  @override
  String approveSheetBody(String role) {
    return 'They asked to be a $role. Confirm that, or change it - the role decides which price list they see.';
  }

  @override
  String get approveSheetWarning => 'They picked this themselves. Check it is right before approving.';

  @override
  String approveSheetConfirm(String role) {
    return 'Approve as $role';
  }

  @override
  String rejectSheetTitle(String firm) {
    return 'Reject $firm';
  }

  @override
  String get rejectSheetBody => 'Choose a reason. The dealer sees this, so keep it plain.';

  @override
  String get rejectReasonNotBusiness => 'Not a registered business';

  @override
  String get rejectReasonDuplicate => 'Duplicate account';

  @override
  String get rejectReasonOutsideArea => 'Outside service area';

  @override
  String get rejectReasonOther => 'Other';

  @override
  String get rejectNotesLabel => 'Anything to add';

  @override
  String get rejectNotesHint => 'Optional detail for the dealer';

  @override
  String get rejectPickReason => 'Choose a reason first';

  @override
  String get rejectNeedsNote => 'Describe the reason';

  @override
  String get actionConfirmReject => 'Reject dealer';

  @override
  String get directorySegmentAll => 'All';

  @override
  String get directorySegmentWholesalers => 'Wholesalers';

  @override
  String get directorySegmentRetailers => 'Retailers';

  @override
  String get directorySegmentSuspended => 'Suspended';

  @override
  String get directorySearchHint => 'Search firm, name, phone or city';

  @override
  String get directoryEmptyTitle => 'No dealers here yet';

  @override
  String get directoryEmptyBody => 'Approved dealers appear in this list.';

  @override
  String get directoryNoResultsTitle => 'No matches';

  @override
  String get directoryNoResultsBody => 'Try a different firm name, phone number or city.';

  @override
  String directoryPendingBanner(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dealers are waiting for approval',
      one: '1 dealer is waiting for approval',
    );
    return '$_temp0';
  }

  @override
  String get dealerDetailTitle => 'Dealer';

  @override
  String get dealerApprovedOn => 'Approved on';

  @override
  String get dealerApprovedBy => 'Approved by';

  @override
  String get dealerApprovedByYou => 'You';

  @override
  String get dealerRegisteredOn => 'Registered on';

  @override
  String get dealerTotalScans => 'Total scans';

  @override
  String get dealerLastActive => 'Last active';

  @override
  String get dealerNeverActive => 'Never used the app';

  @override
  String get dealerAddressLabel => 'Address';

  @override
  String get dealerNoAddress => 'Not provided';

  @override
  String get dealerChangeRole => 'Change role';

  @override
  String dealerChangeRoleTitle(String firm) {
    return 'Change role for $firm';
  }

  @override
  String get dealerChangeRoleBody => 'This changes which price list they see from their next sign-in.';

  @override
  String dealerRoleChanged(String firm, String role) {
    return '$firm is now a $role';
  }

  @override
  String get dealerResetPassword => 'Send password reset';

  @override
  String get dealerResetPasswordTitle => 'Send a reset link?';

  @override
  String dealerResetPasswordBody(String firm) {
    return '$firm will get an email with a link to set a new password. You will not see the password.';
  }

  @override
  String get dealerResetPasswordSent => 'Reset link sent';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardNeedsAttention => 'Needs your attention';

  @override
  String dashboardPendingCta(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dealers waiting',
      one: '1 dealer waiting',
    );
    return '$_temp0';
  }

  @override
  String get dashboardPendingClear => 'No requests waiting';

  @override
  String get dashboardCatalogue => 'Catalogue';

  @override
  String get dashboardNetwork => 'Dealer network';

  @override
  String get dashboardTopScanned => 'Most scanned, last 30 days';

  @override
  String get dashboardTopScannedEmpty => 'No scans recorded yet. Counts appear once dealers start scanning.';

  @override
  String dashboardScanCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString scans',
      one: '1 scan',
    );
    return '$_temp0';
  }

  @override
  String get dashboardRecentlyAdded => 'Recently added';

  @override
  String get dashboardActivity => 'Recent dealer activity';

  @override
  String get dashboardActivityEmpty => 'No dealer decisions yet.';

  @override
  String get dashboardCardFailed => 'Could not load this';

  @override
  String get statActiveProducts => 'Active';

  @override
  String get statWholesalers => 'Wholesalers';

  @override
  String get statRetailers => 'Retailers';

  @override
  String get statSuspended => 'Suspended';

  @override
  String get actionViewRequests => 'View requests';

  @override
  String activityApproved(String firm) {
    return '$firm approved';
  }

  @override
  String activityRejected(String firm) {
    return '$firm rejected';
  }

  @override
  String activitySuspended(String firm) {
    return '$firm suspended';
  }

  @override
  String activityReactivated(String firm) {
    return '$firm reactivated';
  }

  @override
  String activityRoleChanged(String firm) {
    return '$firm role changed';
  }

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String timeHours(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString days ago',
      one: 'yesterday',
    );
    return '$_temp0';
  }

  @override
  String get moreProfile => 'Your profile';

  @override
  String get moreChangePassword => 'Change password';

  @override
  String get moreBusinessDetails => 'Business details';

  @override
  String get moreBusinessDetailsHelp => 'Printed on labels and exports';

  @override
  String get moreLanguage => 'Language';

  @override
  String get moreLanguageSystem => 'Device language';

  @override
  String get moreExportCatalogue => 'Export catalogue (PDF)';

  @override
  String get moreExportCatalogueHelp => 'Both price columns. Do not share with dealers.';

  @override
  String get moreExportDealers => 'Export dealer list (CSV)';

  @override
  String get moreSupport => 'Contact Krishna AI Links';

  @override
  String get moreSupportHelp => 'App support and changes';

  @override
  String get moreExportEmpty => 'There is nothing to export yet.';

  @override
  String get moreExportFailed => 'The export could not be created.';

  @override
  String get businessTitle => 'Business details';

  @override
  String get businessIntro => 'These appear on every printed label and on the catalogue export. Changing them here updates the next thing you print.';

  @override
  String get businessNameLabel => 'Business name';

  @override
  String get businessPhoneLabel => 'Phone';

  @override
  String get businessAddressLabel => 'Address';

  @override
  String get businessSaved => 'Business details saved';

  @override
  String get businessPreview => 'Label preview';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get passwordTitle => 'Change password';

  @override
  String get passwordNewLabel => 'New password';

  @override
  String get passwordConfirmLabel => 'Confirm new password';

  @override
  String get passwordMismatch => 'The two passwords do not match';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get languageTitle => 'App language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGujarati => 'ગુજરાતી';

  @override
  String get errorRevokedTitle => 'Your account is no longer active';

  @override
  String get errorRevokedBody => 'Maruti Water Solution has paused your access. Contact them to restore it.';

  @override
  String get navCatalogue => 'Catalogue';

  @override
  String get navScan => 'Scan';

  @override
  String get navSaved => 'Saved';

  @override
  String get navAccount => 'Account';

  @override
  String get catalogueTitle => 'Catalogue';

  @override
  String get catalogueSearchHint => 'Search by name, model or code';

  @override
  String get catalogueEmptyTitle => 'Nothing in the catalogue yet';

  @override
  String get catalogueEmptyBody => 'Products added by Maruti Water Solution will appear here.';

  @override
  String get catalogueNoResultsTitle => 'No matching products';

  @override
  String get catalogueNoResultsBody => 'Try a different name, model number or category.';

  @override
  String get labelWholesalePrice => 'Wholesale price';

  @override
  String get labelRetailPrice => 'Retail price';

  @override
  String get catalogueSortName => 'Name';

  @override
  String get catalogueSortPriceLow => 'Price: low to high';

  @override
  String get catalogueSortPriceHigh => 'Price: high to low';

  @override
  String get catalogueSortLabel => 'Sort';

  @override
  String catalogueCountLabel(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get offlineBannerTitle => 'Offline — showing saved catalogue';

  @override
  String offlineBannerUpdated(String age) {
    return 'Last updated $age';
  }

  @override
  String get offlineExpiredTitle => 'Saved catalogue is out of date';

  @override
  String get offlineExpiredBody => 'This catalogue is more than 7 days old, so prices may have changed. Connect to the internet to refresh it.';

  @override
  String get offlineRefreshing => 'Refreshing in the background';

  @override
  String get scanTitle => 'Scan a product';

  @override
  String get scanHint => 'Point the camera at the barcode or QR code on the label';

  @override
  String get scanTorchOn => 'Turn on the light';

  @override
  String get scanTorchOff => 'Turn off the light';

  @override
  String get scanFlipCamera => 'Switch camera';

  @override
  String get scanManualEntry => 'Enter code manually';

  @override
  String get scanManualTitle => 'Enter the product code';

  @override
  String get scanManualHint => 'MWS-DOM-001042-Z';

  @override
  String get scanManualHelp => 'The code is printed under the barcode on the label.';

  @override
  String get scanInvalidCode => 'Invalid code.';

  @override
  String get scanUnknownCode => 'That code is valid but no product matches it';

  @override
  String get scanLookupFailed => 'Could not look that up. Check your connection.';

  @override
  String get scanPermissionTitle => 'Camera access is needed to scan';

  @override
  String get scanPermissionBody => 'Allow camera access so the app can read barcodes on your product labels.';

  @override
  String get scanPermissionDeniedBody => 'Camera access is turned off for this app. Turn it on in Settings to scan.';

  @override
  String get scanCameraFailed => 'The camera could not be started';

  @override
  String get scanSearching => 'Looking up the code';

  @override
  String get productDetailTitle => 'Product';

  @override
  String get productNoImages => 'No photos for this product';

  @override
  String get productSpecifications => 'Specifications';

  @override
  String get productNoSpecifications => 'No specifications listed';

  @override
  String productWarranty(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString months warranty',
      one: '1 month warranty',
    );
    return '$_temp0';
  }

  @override
  String get productDescription => 'Description';

  @override
  String get actionSaved => 'Saved';

  @override
  String productSavedToast(String name) {
    return '$name saved';
  }

  @override
  String productUnsavedToast(String name) {
    return '$name removed from saved';
  }

  @override
  String get actionEnquire => 'Enquire';

  @override
  String get productShareFailed => 'Could not open the share sheet';

  @override
  String get productZoomHint => 'Pinch to zoom';

  @override
  String shareHeading(String business) {
    return '$business — product details';
  }

  @override
  String get shareCodeLabel => 'Code';

  @override
  String get sharePriceLabel => 'Price';

  @override
  String shareEnquiry(String name, String code) {
    return 'Hello, I would like to enquire about $name ($code).';
  }

  @override
  String get savedTitle => 'Saved products';

  @override
  String get savedSearchHint => 'Search saved products';

  @override
  String get savedEmptyTitle => 'Nothing saved yet';

  @override
  String get savedEmptyBody => 'Save a product from the catalogue and it will appear here, ready to quote.';

  @override
  String get savedRemove => 'Remove';

  @override
  String get savedExportPdf => 'Export as PDF';

  @override
  String get savedExportFailed => 'The quotation could not be created';

  @override
  String savedCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString saved products',
      one: '1 saved product',
    );
    return '$_temp0';
  }

  @override
  String get quotationTitle => 'Quotation';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountCacheSection => 'Offline catalogue';

  @override
  String accountCacheStatus(int count, String size) {
    return '$count products saved on this phone, $size';
  }

  @override
  String get accountCacheEmpty => 'Nothing saved for offline use yet';

  @override
  String accountCacheUpdated(String age) {
    return 'Updated $age';
  }

  @override
  String get accountClearCache => 'Clear offline catalogue';

  @override
  String get accountClearCacheTitle => 'Clear the offline catalogue?';

  @override
  String get accountClearCacheBody => 'The catalogue will be downloaded again next time you have signal. Your saved products are kept.';

  @override
  String get accountCacheCleared => 'Offline catalogue cleared';

  @override
  String get actionClose => 'Close';

  @override
  String get scanPermissionAllow => 'Allow camera access';

  @override
  String get savedNoResultsTitle => 'No matching saved products';

  @override
  String get savedNoResultsBody => 'Try a different name, model number or code.';

  @override
  String get scanManualFieldLabel => 'Product code';

  @override
  String get complaintsTitle => 'Complaints & Support';

  @override
  String get complaintsSubtitle => 'Track and submit issues or service requests';

  @override
  String get complaintNewButton => 'New Complaint';

  @override
  String get complaintFieldSubject => 'Subject / Title';

  @override
  String get complaintFieldCategory => 'Category';

  @override
  String get complaintFieldProduct => 'Related Product (Optional)';

  @override
  String get complaintFieldReference => 'Order / Invoice Reference (Optional)';

  @override
  String get complaintFieldPriority => 'Priority';

  @override
  String get complaintFieldDescription => 'Description';

  @override
  String get complaintFieldAttachments => 'Attachments / Photos';

  @override
  String get complaintAddPhoto => 'Add Photo';

  @override
  String get complaintSubmitButton => 'Submit Complaint';

  @override
  String get complaintSubmittedTitle => 'Complaint Submitted';

  @override
  String complaintSubmittedBody(String ticketNumber) {
    return 'Your complaint has been logged under ticket number $ticketNumber.';
  }

  @override
  String get complaintEmptyTitle => 'No Complaints Found';

  @override
  String get complaintEmptyBody => 'You have not submitted any complaints yet.';

  @override
  String get complaintCategoryProductIssue => 'Product Issue';

  @override
  String get complaintCategoryInstallationIssue => 'Installation Issue';

  @override
  String get complaintCategoryWarrantyIssue => 'Warranty Issue';

  @override
  String get complaintCategoryDeliveryIssue => 'Delivery Issue';

  @override
  String get complaintCategoryBillingIssue => 'Billing Issue';

  @override
  String get complaintCategoryTechnicalIssue => 'Technical Issue';

  @override
  String get complaintCategoryOther => 'Other';

  @override
  String get complaintPriorityLow => 'Low';

  @override
  String get complaintPriorityMedium => 'Medium';

  @override
  String get complaintPriorityHigh => 'High';

  @override
  String get complaintPriorityUrgent => 'Urgent';

  @override
  String get complaintStatusOpen => 'Open';

  @override
  String get complaintStatusInProgress => 'In Progress';

  @override
  String get complaintStatusResolved => 'Resolved';

  @override
  String get complaintStatusClosed => 'Closed';

  @override
  String get complaintMessagesHeader => 'Updates & Messages';

  @override
  String get complaintAddMessageHint => 'Type a message or response...';

  @override
  String get complaintSendButton => 'Send';

  @override
  String get complaintInternalNoteLabel => 'Internal Admin Note (Owner only)';

  @override
  String get ownerComplaintsTitle => 'Complaint Management';

  @override
  String get ownerComplaintsSubtitle => 'Manage dealer service tickets and responses';

  @override
  String get unitDetailsTitle => 'Product Unit Details';

  @override
  String get unitNotFoundTitle => 'Product Unit Not Found';

  @override
  String get unitNotFoundBody => 'That unit serial code was not found in Maruti Water Solution database.';

  @override
  String get unitActionRaiseComplaint => 'Raise Service Complaint';

  @override
  String get unitSectionMachineTitle => 'Machine Information';

  @override
  String get unitLabelSerialNumber => 'Serial Number';

  @override
  String get unitLabelManufacturedAt => 'Manufactured Date';

  @override
  String get unitSerialCopied => 'Serial number copied to clipboard';

  @override
  String get unitSectionWarrantyTitle => 'Warranty Status';

  @override
  String get warrantyStatusActive => 'Active';

  @override
  String get warrantyStatusExpired => 'Expired';

  @override
  String get warrantyStatusUnactivated => 'Standard Warranty';

  @override
  String get warrantyLabelStandardCoverage => 'Standard Coverage';

  @override
  String get unitMonths => 'Months';

  @override
  String get warrantyLabelCustomerName => 'Customer Name';

  @override
  String get warrantyLabelCustomerPhone => 'Customer Phone';

  @override
  String get warrantyLabelInstallationDate => 'Installation Date';

  @override
  String get warrantyLabelEndDate => 'Warranty Expiry Date';

  @override
  String get warrantyLabelInvoiceNumber => 'Invoice Number';

  @override
  String get warrantyUnactivatedHelp => 'Standard factory warranty applies. Warranty registration will be activated upon unit installation.';

  @override
  String get manageBannersTitle => 'Manage Banners';

  @override
  String get manageBannersSubtitle => 'Manage home dashboard promotional carousel banners';

  @override
  String get actionAddBanner => 'Add Banner';

  @override
  String get bannerStatusActive => 'Active';

  @override
  String get bannerStatusInactive => 'Inactive';

  @override
  String get bannerActionReplace => 'Replace Image';

  @override
  String get bannerActionMoveUp => 'Move Up';

  @override
  String get bannerActionMoveDown => 'Move Down';

  @override
  String get bannerActionDelete => 'Delete Banner';

  @override
  String get bannerDeleteConfirmTitle => 'Delete Banner?';

  @override
  String get bannerDeleteConfirmBody => 'Are you sure you want to delete this banner? This action cannot be undone.';

  @override
  String get bannerRecommendedHint => 'Recommended format: 16:7 aspect ratio wide banner image.';

  @override
  String get bannerEmptyTitle => 'No Banners Added';

  @override
  String get bannerEmptyBody => 'Tap Add Banner to upload promotional slider images for the user dashboard.';

  @override
  String get bannerUploadSuccess => 'Banner uploaded successfully';

  @override
  String get bannerDeleteSuccess => 'Banner deleted successfully';

  @override
  String get scanOptionRegisterProduct => 'Register Product';

  @override
  String get scanOptionClaimWarranty => 'Claim / Warranty';

  @override
  String get scanOptionScanCode => 'Scan Code';

  @override
  String get scanFromGallery => 'Scan from Gallery';

  @override
  String get scanNoQrFound => 'No QR code found in this image.';

  @override
  String get scanMultipleQrFound => 'Multiple QR codes found. Please select an image containing one QR code.';
}
