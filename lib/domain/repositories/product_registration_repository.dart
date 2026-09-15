import '../../core/errors/result.dart';
import '../models/product_lookup.dart';

/// Repository contract for product lookup and warranty registration management.
abstract interface class ProductRegistrationRepository {
  /// Looks up product details and active warranty registration by product barcode / code.
  Future<Result<ProductLookup?>> findProductByBarcode(String barcode);

  /// Registers a product for customer warranty.
  Future<Result<ProductRegistrationInfo>> registerUnit({
    required String unitId,
    required String customerName,
    required String customerPhone,
    required DateTime purchaseDate,
    required DateTime installationDate,
    required int warrantyMonths,
    String? customerCity,
    String? customerAddress,
    String? invoiceNumber,
    String? sellerName,
    String? sellerPhone,
    String? registeredRole,
  });

  /// Updates an existing registration record.
  Future<Result<ProductRegistrationInfo>> updateRegistration({
    required String registrationId,
    required String customerName,
    required String customerPhone,
    String? customerCity,
    String? customerAddress,
    String? invoiceNumber,
    String? sellerName,
    String? sellerPhone,
  });

  /// Deletes a registration record.
  Future<Result<void>> deleteRegistration(String registrationId);

  /// Fetches registered products (all for owner, or filtered by user).
  Future<Result<List<ProductLookup>>> fetchRegistrations({String? userId});
}
