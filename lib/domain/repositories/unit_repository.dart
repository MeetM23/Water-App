import '../../core/errors/result.dart';
import '../models/product_unit.dart';

/// Repository contract for physical RO units and warranty management.
abstract interface class UnitRepository {
  /// Looks up an individual physical RO unit and its active warranty registration by serial number.
  ///
  /// Calls the `lookup_unit_by_serial` RPC. Returns `Success(null)` if serial is not found.
  Future<Result<ProductUnit?>> findUnitBySerial(String serialNumber);

  /// Batch generates [quantity] physical unit serial numbers for [productId].
  Future<Result<List<String>>> batchGenerateUnits({
    required String productId,
    required int quantity,
  });
}
