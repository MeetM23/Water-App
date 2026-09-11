/// Every path in the app, in one place.
abstract final class AppRoutes {
  /// Cold-start screen. Held until the session has resolved.
  static const String splash = '/';

  /// Email and password sign-in.
  static const String login = '/login';

  /// Dealer registration.
  static const String signup = '/signup';

  /// Shown while the owner has not yet decided on the account.
  static const String pending = '/pending';

  /// Shown when the owner turned the account down.
  static const String rejected = '/rejected';

  /// Shown when a previously approved account was paused.
  static const String suspended = '/suspended';

  /// Landing route for an approved owner.
  static const String owner = '/owner';

  /// Landing route for an approved wholesaler.
  static const String wholesaler = '/wholesaler';

  /// Landing route for an approved retailer.
  static const String retailer = '/retailer';

  /// Owner catalogue tab.
  static const String ownerProducts = '/owner/products';

  /// New-product form.
  static const String ownerProductNew = '/owner/products/new';

  /// Owner dealer-network tab.
  static const String ownerDealers = '/owner/dealers';

  /// The queue of dealers awaiting a decision.
  static const String ownerDealerRequests = '/owner/dealers/requests';

  /// Path of the detail screen for the dealer [userId].
  ///
  /// Guarded against colliding with [ownerDealerRequests]: `requests` is not a
  /// uuid, and the router matches the literal route first.
  static String ownerDealerDetail(String userId) => '$ownerDealers/$userId';

  /// Owner secondary tab.
  static const String ownerMore = '/owner/more';

  /// Owner label printing screen.
  static const String ownerPrintLabels = '/owner/print-labels';

  /// Owner banner management screen.
  static const String ownerBanners = '/owner/banners';

  /// Owner product registrations management screen.
  static const String ownerRegistrations = '/owner/registrations';

  /// Owner warranty claims management screen.
  static const String ownerClaims = '/owner/claims';

  /// Owner claim detail screen path.
  static String ownerClaimDetail(String claimId) => '/owner/claims/$claimId';

  /// User's registered physical units screen.
  static const String userRegistrations = '/user/registrations';

  /// User's submitted warranty claims screen.
  static const String userClaims = '/user/claims';

  /// Path of the detail screen for [productId].
  static String ownerProductDetail(String productId) =>
      '$ownerProducts/$productId';

  /// Path of the edit form for [productId].
  static String ownerProductEdit(String productId) =>
      '$ownerProducts/$productId/edit';

  /// Owner profile, read-only.
  static const String ownerProfile = '/owner/more/profile';

  /// Change the owner's own password.
  static const String ownerPassword = '/owner/more/password';

  /// Business details printed on labels and exports.
  static const String ownerBusiness = '/owner/more/business';

  /// Wholesaler catalogue tab.
  static const String wholesalerCatalogue = '/wholesaler/catalogue';

  /// Wholesaler scanner tab.
  static const String wholesalerScan = '/wholesaler/scan';

  /// Wholesaler saved-list tab.
  static const String wholesalerSaved = '/wholesaler/saved';

  /// Wholesaler account tab.
  static const String wholesalerAccount = '/wholesaler/account';

  /// Change the signed-in dealer's own password.
  static const String wholesalerPassword = '/wholesaler/account/password';

  /// Path of the wholesaler-facing detail screen for [productCode].
  ///
  /// Keyed by the printed product code rather than by the uuid, because the
  /// scanner has the code and nothing else, and because a code in a URL is
  /// something a dealer could read out over the phone.
  static String wholesalerProduct(String productCode) =>
      '/wholesaler/product/$productCode';

  /// Retailer catalogue tab.
  static const String retailerCatalogue = '/retailer/catalogue';

  /// Retailer scanner tab.
  static const String retailerScan = '/retailer/scan';

  /// Retailer saved-list tab.
  static const String retailerSaved = '/retailer/saved';

  /// Retailer account tab.
  static const String retailerAccount = '/retailer/account';

  /// Change the signed-in retailer's own password.
  static const String retailerPassword = '/retailer/account/password';

  /// Path of the retailer-facing detail screen for [productCode].
  ///
  /// A separate path from [wholesalerProduct] rather than one shared dealer
  /// path: the redirect decides what a role may reach by matching the prefix of
  /// the location, so a single `/dealer/product/<code>` would have to be
  /// excluded from that test by hand, and the exclusion is exactly the kind of
  /// thing that rots.
  static String retailerProduct(String productCode) =>
      '/retailer/product/$productCode';

  /// Hidden design-system gallery. Not linked from any screen.
  static const String components = '/dev/components';

  /// Dealer complaints list.
  static const String complaints = '/complaints';

  /// New complaint submission form.
  static const String createComplaint = '/complaint/new';

  /// Dealer complaint detail path helper.
  static String complaintDetailPath(String id) => '/complaint/$id';

  /// Owner complaints list.
  static const String ownerComplaints = '/owner/complaints';

  /// Owner complaint detail path helper.
  static String ownerComplaintDetailPath(String id) => '/owner/complaints/$id';

  /// Dedicated product/unit registration form.
  static const String productRegistration = '/unit/register';

  /// Dedicated warranty claim submission form.
  static const String warrantyClaim = '/warranty-claim';

  /// Full-screen serial scanner for the Register Product workflow.
  ///
  /// Pushed from [ProductRegistrationScreen] when the user taps the scan
  /// button inside the form. The scanner runs in ScanMode.registerProduct
  /// and, on a valid MWS-SN scan, pushes [productRegistration] with the
  /// serial as a query parameter.
  static const String serialScanRegister = '/scan-serial/register';

  /// Full-screen serial scanner for the Claim/Warranty workflow.
  ///
  /// Same as [serialScanRegister] but runs in ScanMode.warrantyClaim and
  /// pushes [warrantyClaim] on a successful MWS-SN scan.
  static const String serialScanClaim = '/scan-serial/claim';

  /// Paths a signed-out user is allowed to sit on.
  static const Set<String> signedOutPaths = <String>{
    login,
    signup,
    wholesalerCatalogue,
    wholesalerScan,
    wholesalerSaved,
    wholesalerAccount,
    retailerCatalogue,
    retailerScan,
    retailerSaved,
    retailerAccount,
    productRegistration,
    warrantyClaim,
  };

  /// Whether [path] is accessible to an unauthenticated guest user.
  static bool isGuestPath(String path) {
    if (signedOutPaths.contains(path)) return true;
    if (path.startsWith('/wholesaler/') || path.startsWith('/retailer/')) {
      return true;
    }
    if (path == wholesaler || path == retailer) return true;
    if (path.startsWith('/unit/') || path == warrantyClaim) return true;
    if (path == serialScanRegister || path == serialScanClaim) return true;
    return false;
  }
}
