import '../../core/errors/result.dart';
import '../models/dealer_activity.dart';
import '../models/paged_result.dart';
import '../models/product.dart';
import '../models/product_draft.dart';
import '../models/product_query.dart';

/// Catalogue reads and writes for the owner.
///
/// Every method returns a [Result]; no Supabase exception crosses this line.
abstract interface class ProductRepository {
  /// Fetches one page of products matching [query].
  Future<Result<PagedResult<Product>>> fetchPage(ProductQuery query);

  /// Loads a single product by id.
  Future<Result<Product>> fetchById(String id);

  /// Inserts a product and returns it, including the code the database issued.
  Future<Result<Product>> create(ProductDraft draft);

  /// Updates an existing product and returns the stored row.
  Future<Result<Product>> update(ProductDraft draft);

  /// Removes a product. Images cascade in the database and are deleted from
  /// storage by the caller.
  Future<Result<void>> delete(String id);

  /// Flips the in-stock flag.
  Future<Result<Product>> setInStock(String id, {required bool inStock});

  /// Flips the active flag.
  Future<Result<Product>> setActive(String id, {required bool isActive});

  /// Counts scan events recorded against a product.
  Future<Result<int>> scanCount(String productId);

  /// Counts used by the dashboard, in one round trip.
  Future<Result<ProductCounts>> counts();

  /// The most-scanned products over the last [days] days.
  Future<Result<List<ScannedProduct>>> topScanned({int days, int limit});

  /// Loads every active product for the catalogue export.
  ///
  /// Deliberately unpaged: a PDF of the catalogue is by definition the whole
  /// catalogue, and it is generated on demand rather than while scrolling.
  Future<Result<List<Product>>> fetchAllForExport();
}

/// Headline catalogue numbers for the dashboard.
class ProductCounts {
  /// Creates a counts snapshot.
  const ProductCounts({
    required this.total,
    required this.outOfStock,
    required this.inactive,
  });

  /// Every product row.
  final int total;

  /// Active products flagged out of stock.
  final int outOfStock;

  /// Products flagged inactive.
  final int inactive;
}
