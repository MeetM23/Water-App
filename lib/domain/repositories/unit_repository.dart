import '../../core/errors/result.dart';
import '../models/product_unit.dart';

/// Repository contract for physical RO units and warranty management.
abstract interface class UnitRepository {
  /// Looks up an individual physical RO unit and its active warranty registration by serial number.
  ///
  /// Calls the `lookup_unit_by_serial` RPC. Returns `Success(null)` if serial is not found.
  Future<Result<ProductUnit?>> findUnitBySerial(String serialNumber);

  /// Registers a physical RO unit for customer warranty.
  Future<Result<UnitRegistrationInfo>> registerUnit({
    required String unitId,
    required String customerName,
    required String customerPhone,
    required DateTime purchaseDate,
    required DateTime installationDate,
    required int warrantyMonths,
    String? customerCity,
    String? customerAddress,
    String? invoiceNumber,
    String? registeredRole,
  });

  /// Fetches registered physical units (all for owner, or filtered by user).
  Future<Result<List<ProductUnit>>> fetchRegistrations({String? userId});

  /// Batch generates [quantity] physical unit serial numbers for [productId].
  Future<Result<List<String>>> batchGenerateUnits({
    required String productId,
    required int quantity,
  });
}

