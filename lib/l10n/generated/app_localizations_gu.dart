import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appName => 'મારુતિ વોટર';

  @override
  String get actionRetry => 'ફરી પ્રયાસ કરો';

  @override
  String get actionCancel => 'રદ કરો';

  @override
  String get actionSignOut => 'સાઇન આઉટ';

  @override
  String get actionRefresh => 'તાજું કરો';

  @override
  String get actionContinue => 'આગળ વધો';

  @override
  String get errorGenericTitle => 'કંઈક ખોટું થયું';

  @override
  String get errorGenericBody => 'અત્યારે આ પૂર્ણ થઈ શક્યું નથી. કૃપા કરી ફરી પ્રયાસ કરો.';

  @override
  String get errorNetworkTitle => 'ઇન્ટરનેટ કનેક્શન નથી';

  @override
  String get errorNetworkBody => 'તમારો મોબાઇલ ડેટા અથવા વાઇ-ફાઇ તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get errorServerTitle => 'મારુતિ વોટર જવાબ આપતું નથી';

  @override
  String get errorServerBody => 'સેવા થોડા સમય માટે ઉપલબ્ધ નથી. કૃપા કરી થોડી વારે પ્રયાસ કરો.';

  @override
  String get errorRateLimitedTitle => 'ઘણા બધા પ્રયાસો';

  @override
  String get errorRateLimitedBody => 'કૃપા કરી થોડી મિનિટ રાહ જોઈને ફરી પ્રયાસ કરો.';

  @override
  String get errorSessionExpiredTitle => 'તમને સાઇન આઉટ કરવામાં આવ્યા છે';

  @override
  String get errorSessionExpiredBody => 'તમારું સત્ર સમાપ્ત થયું છે. કૃપા કરી ફરી સાઇન ઇન કરો.';

  @override
  String validationRequired(String field) {
    return '$field જરૂરી છે';
  }

  @override
  String get validationEmail => 'માન્ય ઇમેઇલ સરનામું દાખલ કરો';

  @override
  String get validationPhone => '10 અંકનો મોબાઇલ નંબર દાખલ કરો';

  @override
  String get validationPassword => 'ઓછામાં ઓછા 8 અક્ષરો વાપરો';

  @override
  String get validationGst => 'માન્ય 15 અક્ષરનો GST નંબર દાખલ કરો';

  @override
  String validationTooShort(int count) {
    return 'ઓછામાં ઓછા $count અક્ષરો દાખલ કરો';
  }

  @override
  String get loginTitle => 'સાઇન ઇન';

  @override
  String get loginSubtitle => 'મારુતિ વોટર સોલ્યુશન ડીલર પોર્ટલ';

  @override
  String get loginSubmit => 'સાઇન ઇન';

  @override
  String get loginNoAccount => 'નવા ડીલર છો?';

  @override
  String get loginCreateAccount => 'ખાતું બનાવો';

  @override
  String get loginFailed => 'ઇમેઇલ અથવા પાસવર્ડ ખોટો છે.';

  @override
  String get signupTitle => 'તમારું ખાતું બનાવો';

  @override
  String get signupSubtitle => 'ખાતું ચાલુ થાય તે પહેલાં મારુતિ વોટર સોલ્યુશન દરેક નવા ડીલરની ચકાસણી કરે છે.';

  @override
  String get signupSubmit => 'ખાતું બનાવો';

  @override
  String get signupHaveAccount => 'પહેલેથી નોંધાયેલા છો?';

  @override
  String get signupSignIn => 'સાઇન ઇન';

  @override
  String get signupEmailTaken => 'આ ઇમેઇલ સરનામા માટે ખાતું પહેલેથી છે.';

  @override
  String get signupAccountType => 'ખાતાનો પ્રકાર';

  @override
  String get signupSectionAccount => 'ખાતું';

  @override
  String get signupSectionBusiness => 'વ્યવસાયની વિગતો';

  @override
  String get fieldFullName => 'પૂરું નામ';

  @override
  String get fieldFirmName => 'પેઢીનું નામ';

  @override
  String get fieldPhone => 'ફોન નંબર';

  @override
  String get fieldEmail => 'ઇમેઇલ';

  @override
  String get fieldPassword => 'પાસવર્ડ';

  @override
  String get fieldCity => 'શહેર';

  @override
  String get fieldState => 'રાજ્ય';

  @override
  String get fieldGstNumber => 'GST નંબર';

  @override
  String get fieldOptional => 'વૈકલ્પિક';

  @override
  String get hintPhone => '10 અંકનો મોબાઇલ નંબર';

  @override
  String get hintGstNumber => '24ABCDE1234F1Z5';

  @override
  String get roleWholesaler => 'જથ્થાબંધ વેપારી';

  @override
  String get roleWholesalerHelp => 'તમને જથ્થાબંધ ભાવ દેખાશે';

  @override
  String get roleRetailer => 'છૂટક વેપારી';

  @override
  String get roleRetailerHelp => 'તમને છૂટક ભાવ દેખાશે';

  @override
  String get pendingTitle => 'મંજૂરીની રાહ જોવાઈ રહી છે';

  @override
  String get pendingBody => 'મારુતિ વોટર સોલ્યુશન દરેક નવા ડીલર ખાતાની જાતે ચકાસણી કરે છે. તમારું ખાતું મંજૂર થતાં જ તમે સાઇન ઇન કરી શકશો.';

  @override
  String get pendingFirmLabel => 'નોંધાયેલી પેઢી';

  @override
  String get pendingCheckStatus => 'સ્થિતિ તપાસો';

  @override
  String get pendingStillWaiting => 'તમારું ખાતું હજી મંજૂરીની રાહમાં છે.';

  @override
  String get rejectedTitle => 'ખાતું મંજૂર થયું નથી';

  @override
  String get rejectedBody => 'મારુતિ વોટર સોલ્યુશને આ ખાતું મંજૂર કર્યું નથી.';

  @override
  String get rejectedReasonLabel => 'આપેલું કારણ';

  @override
  String get rejectedNoReason => 'કોઈ કારણ નોંધાયું નથી.';

  @override
  String get suspendedTitle => 'ખાતું સ્થગિત કરાયું છે';

  @override
  String get suspendedBody => 'મારુતિ વોટર સોલ્યુશને આ ખાતાની પહોંચ થોભાવી છે. તેને ફરી ચાલુ કરાવવા સંપર્ક કરો.';

  @override
  String get contactWhatsApp => 'વોટ્સએપ પર સંપર્ક કરો';

  @override
  String get contactUnavailable => 'આ ઉપકરણ પર વોટ્સએપ ખોલી શકાયું નથી.';

  @override
  String get signOutConfirmTitle => 'સાઇન આઉટ કરવું છે?';

  @override
  String get signOutConfirmBody => 'ફરી સાઇન ઇન કરવા માટે તમારે ઇમેઇલ અને પાસવર્ડની જરૂર પડશે.';

  @override
  String get emptyDefaultTitle => 'અહીં હજી કંઈ નથી';

  @override
  String get emptyDefaultBody => 'બતાવવા જેવું કંઈક હશે ત્યારે તે અહીં દેખાશે.';

  @override
  String get actionShow => 'બતાવો';

  @override
  String get actionHide => 'છુપાવો';

  @override
  String get actionClear => 'સાફ કરો';

  @override
  String get homeTitle => 'ખાતું';

  @override
  String get homeSignedInTitle => 'તમે સાઇન ઇન છો';

  @override
  String get homeSignedInBody => 'તમારું ખાતું મંજૂર થયું છે. કેટલોગ આગામી રિલીઝમાં આવશે.';

  @override
  String get labelRole => 'ભૂમિકા';

  @override
  String get labelStatus => 'સ્થિતિ';

  @override
  String get labelFirm => 'પેઢી';

  @override
  String get labelPhone => 'ફોન';

  @override
  String get labelCity => 'શહેર';

  @override
  String get roleOwner => 'માલિક';

  @override
  String get statusPending => 'બાકી';

  @override
  String get statusApproved => 'મંજૂર';

  @override
  String get statusRejected => 'નામંજૂર';

  @override
  String get statusSuspended => 'સ્થગિત';

  @override
  String get hintEmail => 'name@example.com';

  @override
  String get navDashboard => 'ડેશબોર્ડ';

  @override
  String get navProducts => 'ઉત્પાદનો';

  @override
  String get navDealers => 'ડીલરો';

  @override
  String get navMore => 'વધુ';

  @override
  String get actionSave => 'સાચવો';

  @override
  String get actionDelete => 'કાઢી નાખો';

  @override
  String get actionEdit => 'ફેરફાર કરો';

  @override
  String get actionApply => 'લાગુ કરો';

  @override
  String get actionReset => 'રીસેટ કરો';

  @override
  String get actionCopy => 'કૉપિ કરો';

  @override
  String get actionShare => 'શેર કરો';

  @override
  String get actionPrint => 'પ્રિન્ટ કરો';

  @override
  String get actionDone => 'થઈ ગયું';

  @override
  String get actionRemove => 'દૂર કરો';

  @override
  String get actionViewAll => 'બધું જુઓ';

  @override
  String get statTotalProducts => 'ઉત્પાદનો';

  @override
  String get statOutOfStock => 'સ્ટોકમાં નથી';

  @override
  String get statInactive => 'નિષ્ક્રિય';

  @override
  String get statPendingDealers => 'બાકી ડીલરો';

  @override
  String get dashboardQuickActions => 'ઝડપી ક્રિયાઓ';

  @override
  String get dashboardRecentProducts => 'તાજેતરમાં ઉમેરાયેલા';

  @override
  String get actionAddProduct => 'ઉત્પાદન ઉમેરો';

  @override
  String get actionPrintLabels => 'લેબલ પ્રિન્ટ કરો';

  @override
  String get actionReviewDealers => 'ડીલરો તપાસો';

  @override
  String get productsTitle => 'ઉત્પાદનો';

  @override
  String get searchProductsHint => 'નામ, મોડેલ કે કોડ શોધો';

  @override
  String get filterTitle => 'ફિલ્ટર અને ક્રમ';

  @override
  String get filterCategory => 'શ્રેણી';

  @override
  String get filterStatus => 'ઉપલબ્ધતા';

  @override
  String get filterSort => 'આ પ્રમાણે ગોઠવો';

  @override
  String get categoryAll => 'બધી શ્રેણીઓ';

  @override
  String get categoryDomestic => 'ઘરેલું';

  @override
  String get categoryCommercial => 'વાણિજ્યિક';

  @override
  String get categoryIndustrial => 'ઔદ્યોગિક';

  @override
  String get categorySparePart => 'સ્પેર પાર્ટ';

  @override
  String get categoryAccessory => 'એક્સેસરી';

  @override
  String get statusAll => 'બધા';

  @override
  String get statusActive => 'સક્રિય';

  @override
  String get statusInactiveFilter => 'નિષ્ક્રિય';

  @override
  String get statusOutOfStockFilter => 'સ્ટોકમાં નથી';

  @override
  String get sortNewest => 'નવીનતમ પહેલાં';

  @override
  String get sortName => 'નામ';

  @override
  String get sortPriceLowHigh => 'ભાવ, ઓછાથી વધુ';

  @override
  String get sortPriceHighLow => 'ભાવ, વધુથી ઓછા';

  @override
  String get labelWholesale => 'જથ્થાબંધ';

  @override
  String get labelRetail => 'છૂટક';

  @override
  String get labelMrp => 'MRP';

  @override
  String get labelMargin => 'ડીલર માર્જિન';

  @override
  String get badgeInStock => 'સ્ટોકમાં';

  @override
  String get badgeOutOfStock => 'સ્ટોકમાં નથી';

  @override
  String get badgeInactive => 'નિષ્ક્રિય';

  @override
  String get productsEmptyTitle => 'હજી કોઈ ઉત્પાદન નથી';

  @override
  String get productsEmptyBody => 'તમારું પહેલું ઉત્પાદન ઉમેરો, ડેટાબેઝ તેનો કાયમી બારકોડ આપશે.';

  @override
  String get productsNoResultsTitle => 'એવું કંઈ મળ્યું નથી';

  @override
  String get productsNoResultsBody => 'બીજો શબ્દ શોધો, અથવા આખું કેટલોગ જોવા ફિલ્ટર સાફ કરો.';

  @override
  String get productsClearFilters => 'ફિલ્ટર સાફ કરો';

  @override
  String get quickToggleStock => 'સ્ટોક બદલો';

  @override
  String get quickToggleActive => 'સક્રિય બદલો';

  @override
  String get quickDuplicate => 'નકલ કરો';

  @override
  String get deleteProductTitle => 'ઉત્પાદન કાઢી નાખવું છે?';

  @override
  String deleteProductBody(String name) {
    return '$name તેના ફોટા સાથે કેટલોગમાંથી દૂર થશે. આ પાછું લાવી શકાશે નહીં.';
  }

  @override
  String productDeleted(String name) {
    return '$name કાઢી નાખ્યું';
  }

  @override
  String productDuplicated(String name) {
    return '$name ની નકલ થઈ';
  }

  @override
  String get productSaved => 'ઉત્પાદન સાચવ્યું';

  @override
  String get formNewTitle => 'નવું ઉત્પાદન';

  @override
  String get formEditTitle => 'ઉત્પાદનમાં ફેરફાર';

  @override
  String get sectionPhotos => 'ફોટા';

  @override
  String get sectionBasics => 'મૂળ વિગતો';

  @override
  String get sectionSpecifications => 'વિશિષ્ટતાઓ';

  @override
  String get sectionPricing => 'ભાવ';

  @override
  String get sectionAvailability => 'ઉપલબ્ધતા';

  @override
  String photosHelp(int count) {
    return 'વધુમાં વધુ $count ફોટા. પહેલો ફોટો કેટલોગ કાર્ડ પર વપરાય છે.';
  }

  @override
  String get photosAdd => 'ફોટો ઉમેરો';

  @override
  String get photosPrimary => 'મુખ્ય';

  @override
  String get photosSetPrimary => 'મુખ્ય બનાવો';

  @override
  String get photosRemoveTitle => 'ફોટો દૂર કરવો છે?';

  @override
  String get photosRemoveBody => 'આ ફોટો ઉત્પાદન સાથે સાચવવામાં આવશે નહીં.';

  @override
  String photosLimitReached(int count) {
    return 'તમે વધુમાં વધુ $count ફોટા જોડી શકો છો.';
  }

  @override
  String get photosUploadFailed => 'આ ફોટો અપલોડ થઈ શક્યો નથી. ફરી પ્રયાસ કરવા ટૅપ કરો.';

  @override
  String get photosReorderHint => 'ક્રમ બદલવા ફોટો દબાવી રાખો.';

  @override
  String get chooseSourceTitle => 'ફોટો ઉમેરો';

  @override
  String get sourceCamera => 'ફોટો પાડો';

  @override
  String get sourceGallery => 'ગેલેરીમાંથી પસંદ કરો';

  @override
  String get permissionCameraTitle => 'કૅમેરાની પરવાનગી બંધ છે';

  @override
  String get permissionCameraBody => 'ઉત્પાદનનો ફોટો પાડવા મારુતિ વોટરને કૅમેરાની જરૂર છે. તમે સેટિંગ્સમાં તે ચાલુ કરી શકો છો.';

  @override
  String get permissionOpenSettings => 'સેટિંગ્સ ખોલો';

  @override
  String get permissionSettingsFailed => 'આ ઉપકરણ પર સેટિંગ્સ ખોલી શકાયું નથી.';

  @override
  String get fieldProductName => 'ઉત્પાદનનું નામ';

  @override
  String get fieldModelNumber => 'મોડેલ નંબર';

  @override
  String get fieldCategoryLabel => 'શ્રેણી';

  @override
  String get fieldDescription => 'વર્ણન';

  @override
  String get fieldCapacity => 'ક્ષમતા';

  @override
  String get capacityHelp => 'ઉદાહરણ: 25 LPH, અથવા 12 L';

  @override
  String get fieldWarrantyMonths => 'વોરંટી (મહિના)';

  @override
  String get fieldMrpLabel => 'MRP';

  @override
  String get fieldWholesaleLabel => 'જથ્થાબંધ ભાવ';

  @override
  String get fieldRetailLabel => 'છૂટક ભાવ';

  @override
  String get specDetailsLabel => 'વિગતવાર વિશિષ્ટતાઓ';

  @override
  String get specAddRow => 'વિશિષ્ટતા ઉમેરો';

  @override
  String get specKeyHint => 'સ્ટેજ';

  @override
  String get specValueHint => '7';

  @override
  String get specEmpty => 'હજી કોઈ વિશિષ્ટતા નથી. મેમ્બ્રેન કે બોડી મટીરિયલ જેવી પંક્તિઓ ઉમેરો.';

  @override
  String get fieldInStockLabel => 'સ્ટોકમાં';

  @override
  String get fieldInStockHelp => 'ડીલરોને આ ઉત્પાદન ઓર્ડર માટે ઉપલબ્ધ દેખાશે.';

  @override
  String get fieldActiveLabel => 'સક્રિય';

  @override
  String get fieldActiveHelp => 'નિષ્ક્રિય ઉત્પાદનો દરેક ડીલર કેટલોગમાંથી છુપાયેલા રહે છે.';

  @override
  String get priceErrorRetailBelowWholesale => 'છૂટક ભાવ જથ્થાબંધ ભાવ કરતાં ઓછો ન હોઈ શકે';

  @override
  String get priceErrorNotPositive => 'શૂન્યથી વધુ રકમ દાખલ કરો';

  @override
  String get priceWarningAboveMrp => 'આ ભાવ તમે દાખલ કરેલા MRP કરતાં વધારે છે';

  @override
  String get priceWarningZeroMargin => 'છૂટક ભાવ જથ્થાબંધ જેટલો જ છે, ડીલરને કંઈ મળશે નહીં';

  @override
  String marginChip(String amount, String percent) {
    return '$amount માર્જિન ($percent%)';
  }

  @override
  String get marginUnavailable => 'માર્જિન જોવા બંને ભાવ દાખલ કરો';

  @override
  String get unsavedTitle => 'ફેરફારો છોડી દેવા છે?';

  @override
  String get unsavedBody => 'આ ઉત્પાદનમાં કરેલા તમારા ફેરફારો સાચવ્યા નથી.';

  @override
  String get unsavedDiscard => 'છોડી દો';

  @override
  String get unsavedKeepEditing => 'ફેરફાર ચાલુ રાખો';

  @override
  String get formUploadsInFlight => 'ફોટા અપલોડ થાય ત્યાં સુધી રાહ જુઓ';

  @override
  String get createdTitle => 'ઉત્પાદન બન્યું';

  @override
  String get createdBody => 'આ કોડ કાયમી છે અને હવે આ ઉત્પાદનના દરેક લેબલ પર છપાય છે.';

  @override
  String get createdCodeLabel => 'ઉત્પાદન કોડ';

  @override
  String get createdCopied => 'ઉત્પાદન કોડ કૉપિ થયો';

  @override
  String get barcodeCode128 => 'Code 128';

  @override
  String get barcodeQr => 'QR';

  @override
  String detailScanCount(int count) {
    return '$count સ્કેન';
  }

  @override
  String get detailSpecifications => 'વિશિષ્ટતાઓ';

  @override
  String get detailNoSpecifications => 'કોઈ વિશિષ્ટતા નોંધાઈ નથી.';

  @override
  String get detailDescription => 'વર્ણન';

  @override
  String get detailPricing => 'ભાવ';

  @override
  String detailWarranty(int count) {
    return '$count મહિનાની વોરંટી';
  }

  @override
  String get detailNoImages => 'હજી કોઈ ફોટો નથી';

  @override
  String get labelsTitle => 'લેબલ પ્રિન્ટ કરો';

  @override
  String get labelsSelectProducts => 'ઉત્પાદનો પસંદ કરો';

  @override
  String get labelsLayout => 'શીટ લેઆઉટ';

  @override
  String get labelsQuantity => 'ઉત્પાદન દીઠ લેબલ';

  @override
  String labelsSelectedCount(int count) {
    return '$count પસંદ થયા';
  }

  @override
  String labelsSummary(int labels, int sheets) {
    return '$sheets શીટ પર $labels લેબલ';
  }

  @override
  String get labelsPreview => 'પૂર્વાવલોકન';

  @override
  String get labelsEmptyTitle => 'લેબલ માટે ઉત્પાદનો પસંદ કરો';

  @override
  String get labelsEmptyBody => 'એક કે વધુ ઉત્પાદન પસંદ કરો અને દરેકને કેટલા લેબલ જોઈએ તે નક્કી કરો.';

  @override
  String get labelsNoProductsTitle => 'લેબલ માટે કોઈ ઉત્પાદન નથી';

  @override
  String get labelsNoProductsBody => 'પહેલાં ઉત્પાદન ઉમેરો, તે અહીં પ્રિન્ટ માટે તૈયાર દેખાશે.';

  @override
  String labelsBarcodeTooFine(String width, String minimum) {
    return 'આ સ્ટોક પર બાર $width મિમી છપાય છે. હેન્ડહેલ્ડ સ્કેનરને આશરે $minimum મિમી જોઈએ, તેથી આખો પ્રિન્ટ ચલાવતાં પહેલાં એક ટેસ્ટ લેબલ સ્કેન કરો.';
  }

  @override
  String get labelsFilterNotice => 'તમારા કેટલોગ ફિલ્ટર સાથે મેળ ખાતી પ્રોડક્ટ બતાવાય છે. બધું જોવા માટે પ્રોડક્ટ ટેબ પર ફિલ્ટર સાફ કરો.';

  @override
  String get labelsGenerateFailed => 'લેબલ શીટ બની શકી નથી.';

  @override
  String get dealersTitle => 'ડીલરો';

  @override
  String get dealersTabPending => 'બાકી';

  @override
  String get dealersTabApproved => 'મંજૂર';

  @override
  String get dealersTabRejected => 'નામંજૂર';

  @override
  String get dealersTabSuspended => 'સ્થગિત';

  @override
  String get dealersEmptyPendingTitle => 'કોઈ રાહ જોતું નથી';

  @override
  String get dealersEmptyPendingBody => 'નવા ડીલર નોંધણી અહીં દેખાશે, જ્યાં તમે મંજૂર કે નામંજૂર કરી શકશો.';

  @override
  String get dealersEmptyTitle => 'આ યાદીમાં કંઈ નથી';

  @override
  String get dealersEmptyBody => 'તમે જે ડીલરોને આ સ્થિતિમાં મૂકશો તે અહીં દેખાશે.';

  @override
  String get dealerApprove => 'મંજૂર કરો';

  @override
  String get dealerReject => 'નામંજૂર કરો';

  @override
  String get dealerSuspend => 'સ્થગિત કરો';

  @override
  String get dealerReactivate => 'ફરી ચાલુ કરો';

  @override
  String get dealerApproveTitle => 'કઈ ભૂમિકા તરીકે મંજૂર કરવું?';

  @override
  String dealerApproveBody(String name) {
    return '$name ને તમે પસંદ કરેલી ભૂમિકાના ભાવ જ દેખાશે, બીજું કંઈ નહીં.';
  }

  @override
  String dealerRejectTitle(String name) {
    return '$name ને નામંજૂર કરવું છે?';
  }

  @override
  String get dealerRejectBody => 'તેઓ આગલી વખતે એપ ખોલશે ત્યારે તમે આપેલું કારણ જોશે.';

  @override
  String get dealerRejectReason => 'કારણ';

  @override
  String get dealerRejectReasonHint => 'ઉદાહરણ: પેઢીની વિગતો ચકાસી શકાઈ નથી';

  @override
  String dealerSuspendTitle(String name) {
    return '$name ને સ્થગિત કરવું છે?';
  }

  @override
  String get dealerSuspendBody => 'તેમની કેટલોગ પહોંચ તરત બંધ થશે, પહેલેથી સાઇન ઇન કરેલા ઉપકરણ પર પણ.';

  @override
  String dealerReactivateTitle(String name) {
    return '$name ને ફરી ચાલુ કરવું છે?';
  }

  @override
  String get dealerReactivateBody => 'તેમની પહેલાંની ભૂમિકા સાથે કેટલોગ પહોંચ પાછી મળશે.';

  @override
  String dealerApproved(String name) {
    return '$name મંજૂર થયા';
  }

  @override
  String dealerRejectedToast(String name) {
    return '$name નામંજૂર થયા';
  }

  @override
  String dealerSuspendedToast(String name) {
    return '$name સ્થગિત થયા';
  }

  @override
  String dealerReactivatedToast(String name) {
    return '$name ફરી ચાલુ થયા';
  }

  @override
  String get dealerGstLabel => 'GST';

  @override
  String get dealerNoGst => 'આપેલું નથી';

  @override
  String get moreTitle => 'વધુ';

  @override
  String get moreAccount => 'ખાતું';

  @override
  String get moreTools => 'સાધનો';

  @override
  String get moreAbout => 'વિશે';

  @override
  String moreVersion(String version) {
    return 'આવૃત્તિ $version';
  }

  @override
  String get requestsTitle => 'મંજૂરી વિનંતીઓ';

  @override
  String requestsSubtitle(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ડીલર તમારી રાહ જુએ છે',
      one: '1 ડીલર તમારી રાહ જુએ છે',
      zero: 'કંઈ બાકી નથી',
    );
    return '$_temp0';
  }

  @override
  String get requestsEmptyTitle => 'કંઈ બાકી નથી';

  @override
  String get requestsEmptyBody => 'નવી ડીલર નોંધણી તમારા નિર્ણય માટે અહીં દેખાશે.';

  @override
  String requestsTimeAgo(String age) {
    return '$age વિનંતી કરી';
  }

  @override
  String get actionCall => 'કૉલ';

  @override
  String get actionWhatsApp => 'વોટ્સએપ';

  @override
  String get requestedRole => 'માગેલી ભૂમિકા';

  @override
  String approveSheetTitle(String firm) {
    return '$firm ને મંજૂરી આપો';
  }

  @override
  String approveSheetBody(String role) {
    return 'તેમણે $role તરીકે માગ્યું છે. તેની પુષ્ટિ કરો અથવા બદલો - ભૂમિકા નક્કી કરે છે કે તેમને કયો ભાવ દેખાશે.';
  }

  @override
  String get approveSheetWarning => 'આ તેમણે જાતે પસંદ કર્યું છે. મંજૂરી પહેલાં ચકાસો કે તે યોગ્ય છે.';

  @override
  String approveSheetConfirm(String role) {
    return '$role તરીકે મંજૂરી આપો';
  }

  @override
  String rejectSheetTitle(String firm) {
    return '$firm ને નકારો';
  }

  @override
  String get rejectSheetBody => 'કારણ પસંદ કરો. ડીલર આ વાંચશે, તેથી સરળ રાખો.';

  @override
  String get rejectReasonNotBusiness => 'નોંધાયેલ વ્યવસાય નથી';

  @override
  String get rejectReasonDuplicate => 'ડુપ્લિકેટ ખાતું';

  @override
  String get rejectReasonOutsideArea => 'સેવા વિસ્તારની બહાર';

  @override
  String get rejectReasonOther => 'અન્ય';

  @override
  String get rejectNotesLabel => 'વધુ કંઈ ઉમેરવું છે';

  @override
  String get rejectNotesHint => 'ડીલર માટે વૈકલ્પિક વિગત';

  @override
  String get rejectPickReason => 'પહેલાં કારણ પસંદ કરો';

  @override
  String get rejectNeedsNote => 'કારણ જણાવો';

  @override
  String get actionConfirmReject => 'ડીલર નકારો';

  @override
  String get directorySegmentAll => 'બધા';

  @override
  String get directorySegmentWholesalers => 'જથ્થાબંધ';

  @override
  String get directorySegmentRetailers => 'છૂટક';

  @override
  String get directorySegmentSuspended => 'સ્થગિત';

  @override
  String get directorySearchHint => 'પેઢી, નામ, ફોન કે શહેર શોધો';

  @override
  String get directoryEmptyTitle => 'હજી કોઈ ડીલર નથી';

  @override
  String get directoryEmptyBody => 'મંજૂર થયેલા ડીલર આ યાદીમાં દેખાશે.';

  @override
  String get directoryNoResultsTitle => 'કોઈ મેળ નથી';

  @override
  String get directoryNoResultsBody => 'બીજું પેઢીનું નામ, ફોન નંબર કે શહેર અજમાવો.';

  @override
  String directoryPendingBanner(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ડીલર મંજૂરીની રાહ જુએ છે',
      one: '1 ડીલર મંજૂરીની રાહ જુએ છે',
    );
    return '$_temp0';
  }

  @override
  String get dealerDetailTitle => 'ડીલર';

  @override
  String get dealerApprovedOn => 'મંજૂરી તારીખ';

  @override
  String get dealerApprovedBy => 'મંજૂરી આપનાર';

  @override
  String get dealerApprovedByYou => 'તમે';

  @override
  String get dealerRegisteredOn => 'નોંધણી તારીખ';

  @override
  String get dealerTotalScans => 'કુલ સ્કેન';

  @override
  String get dealerLastActive => 'છેલ્લે સક્રિય';

  @override
  String get dealerNeverActive => 'એપ ક્યારેય વાપરી નથી';

  @override
  String get dealerAddressLabel => 'સરનામું';

  @override
  String get dealerNoAddress => 'આપેલ નથી';

  @override
  String get dealerChangeRole => 'ભૂમિકા બદલો';

  @override
  String dealerChangeRoleTitle(String firm) {
    return '$firm ની ભૂમિકા બદલો';
  }

  @override
  String get dealerChangeRoleBody => 'આનાથી તેમના આગલા સાઇન-ઇનથી કયો ભાવ દેખાશે તે બદલાશે.';

  @override
  String dealerRoleChanged(String firm, String role) {
    return '$firm હવે $role છે';
  }

  @override
  String get dealerResetPassword => 'પાસવર્ડ રીસેટ મોકલો';

  @override
  String get dealerResetPasswordTitle => 'રીસેટ લિંક મોકલવી?';

  @override
  String dealerResetPasswordBody(String firm) {
    return '$firm ને નવો પાસવર્ડ સેટ કરવાની લિંક સાથે ઈમેલ મળશે. તમને પાસવર્ડ દેખાશે નહિં.';
  }

  @override
  String get dealerResetPasswordSent => 'રીસેટ લિંક મોકલી';

  @override
  String get dashboardTitle => 'ડેશબોર્ડ';

  @override
  String get dashboardNeedsAttention => 'તમારું ધ્યાન જરૂરી';

  @override
  String dashboardPendingCta(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ડીલર રાહ જુએ છે',
      one: '1 ડીલર રાહ જુએ છે',
    );
    return '$_temp0';
  }

  @override
  String get dashboardPendingClear => 'કોઈ વિનંતી બાકી નથી';

  @override
  String get dashboardCatalogue => 'કેટલોગ';

  @override
  String get dashboardNetwork => 'ડીલર નેટવર્ક';

  @override
  String get dashboardTopScanned => 'છેલ્લા 30 દિવસમાં સૅથી વધુ સ્કેન';

  @override
  String get dashboardTopScannedEmpty => 'હજી કોઈ સ્કેન નોંધાયું નથી. ડીલર સ્કેન કરવાનું શરૂ કરે એટલે ગણતરી દેખાશે.';

  @override
  String dashboardScanCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString સ્કેન',
      one: '1 સ્કેન',
    );
    return '$_temp0';
  }

  @override
  String get dashboardRecentlyAdded => 'તાજેતરમાં ઉમેરેલ';

  @override
  String get dashboardActivity => 'તાજેતરની ડીલર પ્રવૃત્તિ';

  @override
  String get dashboardActivityEmpty => 'હજી કોઈ ડીલર નિર્ણય નથી.';

  @override
  String get dashboardCardFailed => 'આ લોડ થઈ શક્યું નહિં';

  @override
  String get statActiveProducts => 'સક્રિય';

  @override
  String get statWholesalers => 'જથ્થાબંધ';

  @override
  String get statRetailers => 'છૂટક';

  @override
  String get statSuspended => 'સ્થગિત';

  @override
  String get actionViewRequests => 'વિનંતીઓ જુઓ';

  @override
  String activityApproved(String firm) {
    return '$firm ને મંજૂરી મળી';
  }

  @override
  String activityRejected(String firm) {
    return '$firm નકારાયું';
  }

  @override
  String activitySuspended(String firm) {
    return '$firm સ્થગિત';
  }

  @override
  String activityReactivated(String firm) {
    return '$firm ફરી સક્રિય';
  }

  @override
  String activityRoleChanged(String firm) {
    return '$firm ની ભૂમિકા બદલાઈ';
  }

  @override
  String get timeJustNow => 'હમણાં જ';

  @override
  String timeMinutes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString મિનિટ પહેલાં',
      one: '1 મિનિટ પહેલાં',
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
      other: '$countString કલાક પહેલાં',
      one: '1 કલાક પહેલાં',
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
      other: '$countString દિવસ પહેલાં',
      one: 'ગઈકાલે',
    );
    return '$_temp0';
  }

  @override
  String get moreProfile => 'તમારી પ્રોફાઇલ';

  @override
  String get moreChangePassword => 'પાસવર્ડ બદલો';

  @override
  String get moreBusinessDetails => 'વ્યવસાયની વિગતો';

  @override
  String get moreBusinessDetailsHelp => 'લેબલ અને નિકાસ પર છપાય છે';

  @override
  String get moreLanguage => 'ભાષા';

  @override
  String get moreLanguageSystem => 'ઉપકરણની ભાષા';

  @override
  String get moreExportCatalogue => 'કેટલોગ નિકાસ (PDF)';

  @override
  String get moreExportCatalogueHelp => 'બંને ભાવ કૉલમ. ડીલર સાથે શેર ન કરો.';

  @override
  String get moreExportDealers => 'ડીલર યાદી નિકાસ (CSV)';

  @override
  String get moreSupport => 'Krishna AI Links નો સંપર્ક કરો';

  @override
  String get moreSupportHelp => 'એપ સપોર્ટ અને ફેરફારો';

  @override
  String get moreExportEmpty => 'નિકાસ કરવા માટે હજી કંઈ નથી.';

  @override
  String get moreExportFailed => 'નિકાસ બનાવી શકાઈ નહિં.';

  @override
  String get businessTitle => 'વ્યવસાયની વિગતો';

  @override
  String get businessIntro => 'આ દરેક છપાયેલા લેબલ અને કેટલોગ નિકાસ પર દેખાય છે. અહીં બદલવાથી તમે આગળ જે છાપશો તે અપડેટ થશે.';

  @override
  String get businessNameLabel => 'વ્યવસાયનું નામ';

  @override
  String get businessPhoneLabel => 'ફોન';

  @override
  String get businessAddressLabel => 'સરનામું';

  @override
  String get businessSaved => 'વ્યવસાયની વિગતો સાચવી';

  @override
  String get businessPreview => 'લેબલ પૂર્વાવલોકન';

  @override
  String get profileTitle => 'તમારી પ્રોફાઇલ';

  @override
  String get passwordTitle => 'પાસવર્ડ બદલો';

  @override
  String get passwordNewLabel => 'નવો પાસવર્ડ';

  @override
  String get passwordConfirmLabel => 'નવો પાસવર્ડ ફરી લખો';

  @override
  String get passwordMismatch => 'બંને પાસવર્ડ મેળ ખાતા નથી';

  @override
  String get passwordChanged => 'પાસવર્ડ બદલાયો';

  @override
  String get languageTitle => 'એપ ભાષા';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGujarati => 'ગુજરાતી';

  @override
  String get errorRevokedTitle => 'તમારું ખાતું હવે સક્રિય નથી';

  @override
  String get errorRevokedBody => 'મારુતિ વોટર સોલ્યુશને તમારો પ્રવેશ થોભાવ્યો છે. પુનઃ ચાલુ કરવા તેમનો સંપર્ક કરો.';

  @override
  String get navCatalogue => 'કેટલોગ';

  @override
  String get navScan => 'સ્કેન';

  @override
  String get navSaved => 'સાચવેલ';

  @override
  String get navAccount => 'ખાતું';

  @override
  String get catalogueTitle => 'કેટલોગ';

  @override
  String get catalogueSearchHint => 'નામ, મોડેલ કે કોડથી શોધો';

  @override
  String get catalogueEmptyTitle => 'કેટલોગમાં હજી કંઈ નથી';

  @override
  String get catalogueEmptyBody => 'મારુતિ વોટર સોલ્યુશન ઉમેરે તે પ્રોડક્ટ અહીં દેખાશે.';

  @override
  String get catalogueNoResultsTitle => 'કોઈ મેળ ખાતી પ્રોડક્ટ નથી';

  @override
  String get catalogueNoResultsBody => 'બીજું નામ, મોડેલ નંબર કે શ્રેણી અજમાવો.';

  @override
  String get labelWholesalePrice => 'જથ્થાબંધ ભાવ';

  @override
  String get labelRetailPrice => 'છૂટક ભાવ';

  @override
  String get catalogueSortName => 'નામ';

  @override
  String get catalogueSortPriceLow => 'ભાવ: ઓછાથી વધુ';

  @override
  String get catalogueSortPriceHigh => 'ભાવ: વધુથી ઓછા';

  @override
  String get catalogueSortLabel => 'ક્રમ';

  @override
  String catalogueCountLabel(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString પ્રોડક્ટ',
      one: '1 પ્રોડક્ટ',
    );
    return '$_temp0';
  }

  @override
  String get offlineBannerTitle => 'ઓફલાઇન — સાચવેલ કેટલોગ બતાવાય છે';

  @override
  String offlineBannerUpdated(String age) {
    return 'છેલ્લે અપડેટ $age';
  }

  @override
  String get offlineExpiredTitle => 'સાચવેલ કેટલોગ જૂનો છે';

  @override
  String get offlineExpiredBody => 'આ કેટલોગ 7 દિવસથી જૂનો છે, તેથી ભાવ બદલાયા હોઈ શકે. તાજું કરવા ઇન્ટરનેટ સાથે જોડાઓ.';

  @override
  String get offlineRefreshing => 'પૃષ્ઠભૂમિમાં તાજું થાય છે';

  @override
  String get scanTitle => 'પ્રોડક્ટ સ્કેન કરો';

  @override
  String get scanHint => 'લેબલ પરના બારકોડ કે QR કોડ પર કેમેરા રાખો';

  @override
  String get scanTorchOn => 'લાઇટ ચાલુ કરો';

  @override
  String get scanTorchOff => 'લાઇટ બંધ કરો';

  @override
  String get scanFlipCamera => 'કેમેરા બદલો';

  @override
  String get scanManualEntry => 'કોડ જાતે લખો';

  @override
  String get scanManualTitle => 'પ્રોડક્ટ કોડ લખો';

  @override
  String get scanManualHint => 'MWS-DOM-001042-Z';

  @override
  String get scanManualHelp => 'કોડ લેબલ પર બારકોડ નીચે છપાયેલો છે.';

  @override
  String get scanInvalidCode => 'અમાન્ય કોડ.';

  @override
  String get scanUnknownCode => 'કોડ સાચો છે પણ તેની સાથે કોઈ પ્રોડક્ટ મળતી નથી';

  @override
  String get scanLookupFailed => 'શોધી શકાયું નહિં. તમારું જોડાણ તપાસો.';

  @override
  String get scanPermissionTitle => 'સ્કેન કરવા કેમેરાની પરવાનગી જોઈએ';

  @override
  String get scanPermissionBody => 'એપ લેબલ પરના બારકોડ વાંચી શકે તે માટે કેમેરાની પરવાનગી આપો.';

  @override
  String get scanPermissionDeniedBody => 'આ એપ માટે કેમેરા બંધ છે. સ્કેન કરવા સેટિંગ્સમાં ચાલુ કરો.';

  @override
  String get scanCameraFailed => 'કેમેરા શરૂ થઈ શક્યો નહિં';

  @override
  String get scanSearching => 'કોડ શોધાય છે';

  @override
  String get productDetailTitle => 'પ્રોડક્ટ';

  @override
  String get productNoImages => 'આ પ્રોડક્ટ માટે ફોટો નથી';

  @override
  String get productSpecifications => 'વિશિષ્ટતાઓ';

  @override
  String get productNoSpecifications => 'કોઈ વિશિષ્ટતા આપેલ નથી';

  @override
  String productWarranty(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString મહિનાની વોરંટી',
      one: '1 મહિનાની વોરંટી',
    );
    return '$_temp0';
  }

  @override
  String get productDescription => 'વર્ણન';

  @override
  String get actionSaved => 'સાચવેલ';

  @override
  String productSavedToast(String name) {
    return '$name સાચવ્યું';
  }

  @override
  String productUnsavedToast(String name) {
    return '$name સાચવેલમાંથી દૂર કર્યું';
  }

  @override
  String get actionEnquire => 'પૂછપરછ';

  @override
  String get productShareFailed => 'શેર શીટ ખૂલી શકી નહિં';

  @override
  String get productZoomHint => 'ઝૂમ કરવા પિંચ કરો';

  @override
  String shareHeading(String business) {
    return '$business — પ્રોડક્ટ વિગત';
  }

  @override
  String get shareCodeLabel => 'કોડ';

  @override
  String get sharePriceLabel => 'ભાવ';

  @override
  String shareEnquiry(String name, String code) {
    return 'નમસ્તે, મારે $name ($code) વિશે પૂછપરછ કરવી છે.';
  }

  @override
  String get savedTitle => 'સાચવેલ પ્રોડક્ટ';

  @override
  String get savedSearchHint => 'સાચવેલ પ્રોડક્ટ શોધો';

  @override
  String get savedEmptyTitle => 'હજી કંઈ સાચવ્યું નથી';

  @override
  String get savedEmptyBody => 'કેટલોગમાંથી પ્રોડક્ટ સાચવો, તે અહીં ભાવપત્રક માટે તૈયાર દેખાશે.';

  @override
  String get savedRemove => 'દૂર કરો';

  @override
  String get savedExportPdf => 'PDF તરીકે નિકાસ કરો';

  @override
  String get savedExportFailed => 'ભાવપત્રક બનાવી શકાયું નહિં';

  @override
  String savedCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString સાચવેલ પ્રોડક્ટ',
      one: '1 સાચવેલ પ્રોડક્ટ',
    );
    return '$_temp0';
  }

  @override
  String get quotationTitle => 'ભાવપત્રક';

  @override
  String get accountTitle => 'ખાતું';

  @override
  String get accountCacheSection => 'ઓફલાઇન કેટલોગ';

  @override
  String accountCacheStatus(int count, String size) {
    return 'આ ફોનમાં $count પ્રોડક્ટ સાચવેલી, $size';
  }

  @override
  String get accountCacheEmpty => 'ઓફલાઇન વપરાશ માટે હજી કંઈ સાચવ્યું નથી';

  @override
  String accountCacheUpdated(String age) {
    return 'અપડેટ $age';
  }

  @override
  String get accountClearCache => 'ઓફલાઇન કેટલોગ સાફ કરો';

  @override
  String get accountClearCacheTitle => 'ઓફલાઇન કેટલોગ સાફ કરવો?';

  @override
  String get accountClearCacheBody => 'આગલી વખતે સિગ્નલ મળે ત્યારે કેટલોગ ફરી ડાઉનલોડ થશે. તમારી સાચવેલ પ્રોડક્ટ રહેશે.';

  @override
  String get accountCacheCleared => 'ઓફલાઇન કેટલોગ સાફ કર્યો';

  @override
  String get actionClose => 'બંધ કરો';

  @override
  String get scanPermissionAllow => 'કેમેરાની પરવાનગી આપો';

  @override
  String get savedNoResultsTitle => 'કોઈ મેળ ખાતી સાચવેલ પ્રોડક્ટ નથી';

  @override
  String get savedNoResultsBody => 'બીજું નામ, મોડેલ નંબર કે કોડ અજમાવો.';

  @override
  String get scanManualFieldLabel => 'પ્રોડક્ટ કોડ';

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
  String get unitDetailsTitle => 'પ્રોડક્ટ યુનિટ વિગત';

  @override
  String get unitNotFoundTitle => 'પ્રોડક્ટ યુનિટ મળ્યું નથી';

  @override
  String get unitNotFoundBody => 'આ યુનિટ સીરિયલ કોડ મારુતિ વોટર સોલ્યુશન ડેટાબેઝમાં મળ્યો નથી.';

  @override
  String get unitActionRaiseComplaint => 'સર્વિસ ફરિયાદ કરો';

  @override
  String get unitSectionMachineTitle => 'મશીનની માહિતી';

  @override
  String get unitLabelSerialNumber => 'સીરિયલ નંબર';

  @override
  String get unitLabelManufacturedAt => 'ઉત્પાદન તારીખ';

  @override
  String get unitSerialCopied => 'સીરિયલ નંબર કોપી થયો';

  @override
  String get unitSectionWarrantyTitle => 'વોરંટી સ્થિતિ';

  @override
  String get warrantyStatusActive => 'સક્રિય';

  @override
  String get warrantyStatusExpired => 'પૂર્ણ થયેલ';

  @override
  String get warrantyStatusUnactivated => 'માનક વોરંટી';

  @override
  String get warrantyLabelStandardCoverage => 'માનક સમગ્રીતા';

  @override
  String get unitMonths => 'મહિના';

  @override
  String get warrantyLabelCustomerName => 'ગ્રાહકનું નામ';

  @override
  String get warrantyLabelCustomerPhone => 'ગ્રાહકનો ફોન';

  @override
  String get warrantyLabelInstallationDate => 'ઇન્સ્ટોલેશન તારીખ';

  @override
  String get warrantyLabelEndDate => 'વોરંટી પૂર્ણ તારીખ';

  @override
  String get warrantyLabelInvoiceNumber => 'ઇન્વોઇસ નંબર';

  @override
  String get warrantyUnactivatedHelp => 'માનક ફેક્ટરી વોરંટી લાગુ થાય છે. ઇન્સ્ટોલેશન વખતે વોરંટી સક્રિય થશે.';

  @override
  String get manageBannersTitle => 'બેનર મેનેજ કરો';

  @override
  String get manageBannersSubtitle => 'હોમ ડેશબોર્ડ સ્લાઇડર બેનર મેનેજ કરો';

  @override
  String get actionAddBanner => 'બેનર ઉમેરો';

  @override
  String get bannerStatusActive => 'સક્રિય';

  @override
  String get bannerStatusInactive => 'નિષ્ક્રિય';

  @override
  String get bannerActionReplace => 'ઇમેજ બદલો';

  @override
  String get bannerActionMoveUp => 'ઉપર ખસેડો';

  @override
  String get bannerActionMoveDown => 'નીચે ખસેડો';

  @override
  String get bannerActionDelete => 'બેનર કાઢી નાખો';

  @override
  String get bannerDeleteConfirmTitle => 'બેનર કાઢી નાખવું છે?';

  @override
  String get bannerDeleteConfirmBody => 'શું તમે ખરેખર આ બેનર કાઢી નાખવા માંગો છો?';

  @override
  String get bannerRecommendedHint => 'ભલામણ કરેલ ફોર્મેટ: 16:7 આસ્પેક્ટ રેશિયો પોહળું બેનર.';

  @override
  String get bannerEmptyTitle => 'કોઈ બેનર ઉમેરેલ નથી';

  @override
  String get bannerEmptyBody => 'યુઝર ડેશબોર્ડ સ્લાઇડર માટે બેનર ઉમેરવા બેનર ઉમેરો પર ટેપ કરો.';

  @override
  String get bannerUploadSuccess => 'બેનર સફળતાપૂર્વક અપલોડ થયું';

  @override
  String get bannerDeleteSuccess => 'બેનર કાઢી નાખવામાં આવ્યું';

  @override
  String get scanOptionRegisterProduct => 'પ્રોડક્ટ રજીસ્ટર કરો';

  @override
  String get scanOptionClaimWarranty => 'ક્લેમ / વોરંટી';

  @override
  String get scanOptionScanCode => 'કોડ સ્કેન કરો';

  @override
  String get scanFromGallery => 'ગેલેરીમાંથી સ્કેન કરો';

  @override
  String get scanNoQrFound => 'આ ઇમેજમાં કોઈ QR કોડ મળ્યો નથી.';

  @override
  String get scanMultipleQrFound => 'એક કરતાં વધુ QR કોડ મળ્યા. કૃપા કરીને એક QR કોડ ધરાવતી ઇમેજ પસંદ કરો.';
}
