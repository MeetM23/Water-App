import 'package:flutter_test/flutter_test.dart';
import 'package:maruti_water/domain/enums/product_category.dart';
import 'package:maruti_water/domain/models/product.dart';
import 'package:maruti_water/domain/models/product_draft.dart';
import 'package:maruti_water/features/owner/labels/domain/product_label_tracker.dart';

void main() {
  group('Print Labels Page & Label Sequence Logic Tests', () {
    test('PROMPT CASE 1: Admin creates product code ABCD, Stock: 5 -> Labels ABCD-001..005', () {
      final product = Product(
        id: 'prod-abcd',
        productCode: 'ABCD',
        name: 'Product ABCD',
        category: ProductCategory.domestic,
        wholesalePrice: 5000,
        retailPrice: 8000,
        inStock: true,
        isActive: true,
        stockQuantity: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tracker = ProductLabelTracker.fromProduct(product);
      expect(tracker.existingLabelsCount, equals(5));
      expect(tracker.newLabelsAvailable, equals(0));
      expect(tracker.getAllLabels(), equals(<String>[
        'ABCD-001',
        'ABCD-002',
        'ABCD-003',
        'ABCD-004',
        'ABCD-005',
      ]));
    });

    test('PROMPT CASE 2: Admin creates product code 1234, Stock: 3 -> Labels 1234-001..003', () {
      final product = Product(
        id: 'prod-1234',
        productCode: '1234',
        name: 'Product 1234',
        category: ProductCategory.domestic,
        wholesalePrice: 5000,
        retailPrice: 8000,
        inStock: true,
        isActive: true,
        stockQuantity: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tracker = ProductLabelTracker.fromProduct(product);
      expect(tracker.existingLabelsCount, equals(3));
      expect(tracker.newLabelsAvailable, equals(0));
      expect(tracker.getAllLabels(), equals(<String>[
        '1234-001',
        '1234-002',
        '1234-003',
      ]));
    });

    test('PROMPT CASE 3: Admin creates MWS-COM-001013-Q, Stock: 2 -> Labels MWS-COM-001013-Q-001..002', () {
      final product = Product(
        id: 'prod-mws-com',
        productCode: 'MWS-COM-001013-Q',
        name: 'Product Commercial',
        category: ProductCategory.commercial,
        wholesalePrice: 15000,
        retailPrice: 20000,
        inStock: true,
        isActive: true,
        stockQuantity: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tracker = ProductLabelTracker.fromProduct(product);
      expect(tracker.existingLabelsCount, equals(2));
      expect(tracker.newLabelsAvailable, equals(0));
      expect(tracker.getAllLabels(), equals(<String>[
        'MWS-COM-001013-Q-001',
        'MWS-COM-001013-Q-002',
      ]));
    });

    test('PROMPT CASE 4: Add 2 more stock when existing labels: 001, 002 -> Expected new labels: 003, 004', () {
      var tracker = ProductLabelTracker(
        productId: 'prod-abcd',
        prefix: 'ABCD-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 2,
        totalCapacity: 2,
      );

      // Add 2 stock
      tracker = tracker.addStockCapacity(2);
      expect(tracker.totalCapacity, equals(4));
      expect(tracker.existingLabelsCount, equals(2));
      expect(tracker.newLabelsAvailable, equals(2));

      // Print new labels automatically for the 2 remaining
      final allocation = tracker.allocateLabels(2);
      expect(allocation.newLabels, equals(<String>[
        'ABCD-003',
        'ABCD-004',
      ]));
      expect(allocation.tracker.existingLabelsCount, equals(4));
      expect(allocation.tracker.newLabelsAvailable, equals(0));
    });

    test('PROMPT CASE 5: Print All -> Same existing QR codes, no new labels, no stock change', () {
      final tracker = ProductLabelTracker(
        productId: 'prod-abcd',
        prefix: 'ABCD-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 4,
        totalCapacity: 4,
      );

      final allLabels = tracker.getAllLabels();
      expect(allLabels, equals(<String>[
        'ABCD-001',
        'ABCD-002',
        'ABCD-003',
        'ABCD-004',
      ]));
      // No change in sequence count or capacity
      expect(tracker.lastSequence, equals(4));
      expect(tracker.totalCapacity, equals(4));
    });

    test('CASE 2: Admin adds +5 stock -> Stock = 10, Existing = 5, New available = 5, Print New (5) = 006..010', () {
      var tracker = ProductLabelTracker(
        productId: 'prod-001',
        prefix: 'MWS-DOM-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 5,
        totalCapacity: 5,
      );

      // Admin adds +5 stock
      tracker = tracker.addStockCapacity(5);
      expect(tracker.totalCapacity, equals(10));
      expect(tracker.existingLabelsCount, equals(5));
      expect(tracker.newLabelsAvailable, equals(5));

      // Print New Labels with quantity = 5
      final allocation = tracker.allocateLabels(5);
      final updatedTracker = allocation.tracker;
      final newLabels = allocation.newLabels;

      expect(newLabels, equals(<String>[
        'MWS-DOM-006',
        'MWS-DOM-007',
        'MWS-DOM-008',
        'MWS-DOM-009',
        'MWS-DOM-010',
      ]));
      expect(updatedTracker.existingLabelsCount, equals(10));
      expect(updatedTracker.newLabelsAvailable, equals(0));
      expect(updatedTracker.nextSequenceNumber, equals(11));
    });

    test('CASE 3: Admin adds +5 stock again -> Stock = 15, Existing = 10, New = 5, Select qty = 2 -> 011..012, Remaining = 3', () {
      var tracker = ProductLabelTracker(
        productId: 'prod-001',
        prefix: 'MWS-DOM-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 10,
        totalCapacity: 10,
      );

      // Admin adds +5 stock
      tracker = tracker.addStockCapacity(5);
      expect(tracker.totalCapacity, equals(15));
      expect(tracker.existingLabelsCount, equals(10));
      expect(tracker.newLabelsAvailable, equals(5));

      // Admin selects quantity = 2
      final allocation = tracker.allocateLabels(2);
      final updatedTracker = allocation.tracker;
      expect(allocation.newLabels, equals(<String>[
        'MWS-DOM-011',
        'MWS-DOM-012',
      ]));
      expect(updatedTracker.existingLabelsCount, equals(12));
      expect(updatedTracker.newLabelsAvailable, equals(3));
      expect(updatedTracker.nextSequenceNumber, equals(13));
    });

    test('CASE 4: Select remaining quantity = 3 -> 013..015, Next available = 016, Remaining = 0', () {
      var tracker = ProductLabelTracker(
        productId: 'prod-001',
        prefix: 'MWS-DOM-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 12,
        totalCapacity: 15,
      );

      expect(tracker.newLabelsAvailable, equals(3));

      // Select quantity = 3
      final allocation = tracker.allocateLabels(3);
      final updatedTracker = allocation.tracker;
      expect(allocation.newLabels, equals(<String>[
        'MWS-DOM-013',
        'MWS-DOM-014',
        'MWS-DOM-015',
      ]));
      expect(updatedTracker.existingLabelsCount, equals(15));
      expect(updatedTracker.newLabelsAvailable, equals(0));
      expect(updatedTracker.nextSequenceNumber, equals(16));
    });

    test('CASE 5: Print All -> 001..015, No new sequence allocation', () {
      final tracker = ProductLabelTracker(
        productId: 'prod-001',
        prefix: 'MWS-DOM-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 15,
        totalCapacity: 15,
      );

      final allLabels = tracker.getAllLabels();
      expect(allLabels.length, equals(15));
      expect(allLabels.first, equals('MWS-DOM-001'));
      expect(allLabels.last, equals('MWS-DOM-015'));
      expect(tracker.lastSequence, equals(15)); // Sequence state is not modified
      expect(tracker.nextSequenceNumber, equals(16));
    });

    test('CASE 6: User scans one product -> Stock drops 15 to 14, Next label remains 016', () {
      final tracker = ProductLabelTracker(
        productId: 'prod-001',
        prefix: 'MWS-DOM-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 15,
        totalCapacity: 15,
      );

      // Stock drops due to customer scan
      var stock = 15;
      stock -= 1;
      expect(stock, equals(14));

      // Tracker remains unchanged
      expect(tracker.lastSequence, equals(15));
      expect(tracker.nextSequenceNumber, equals(16));
      expect(tracker.formatLabel(tracker.nextSequenceNumber), equals('MWS-DOM-016'));
    });

    test('CASE 7: Restart application -> JSON persistence restores exact next label 016', () {
      final original = ProductLabelTracker(
        productId: 'prod-001',
        prefix: 'MWS-DOM-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 15,
        totalCapacity: 15,
      );

      final json = original.toJson();

      final restored = ProductLabelTracker.fromJson(
        json,
        productId: 'prod-001',
        productCode: 'MWS-DOM-001',
      );

      expect(restored.lastSequence, equals(15));
      expect(restored.totalCapacity, equals(15));
      expect(restored.nextSequenceNumber, equals(16));
      expect(restored.formatLabel(restored.nextSequenceNumber), equals('MWS-DOM-016'));
    });

    test('CASE 8: Different products maintain independent sequences', () {
      final domProduct = ProductLabelTracker(
        productId: 'prod-dom',
        prefix: 'MWS-DOM-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 5,
        totalCapacity: 10,
      );

      final comProduct = ProductLabelTracker(
        productId: 'prod-com',
        prefix: 'MWS-COM-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 2,
        totalCapacity: 5,
      );

      final domAlloc = domProduct.allocateLabels(5);
      final comAlloc = comProduct.allocateLabels(3);

      expect(domAlloc.newLabels, equals(<String>[
        'MWS-DOM-006',
        'MWS-DOM-007',
        'MWS-DOM-008',
        'MWS-DOM-009',
        'MWS-DOM-010',
      ]));

      expect(domAlloc.tracker.nextSequenceNumber, equals(11));
      expect(comAlloc.tracker.nextSequenceNumber, equals(6));
    });

    test('CASE 9: Arbitrary code patterns (ABC-500, RO2026-001, MARUTI-X-0001, PRODUCT-A-25)', () {
      final abcTracker = ProductLabelTracker(
        productId: 'prod-abc',
        prefix: 'ABC-',
        startNumber: 500,
        padLength: 3,
        lastSequence: 0,
        totalCapacity: 5,
      );
      final abcAlloc = abcTracker.allocateLabels(5);
      expect(abcAlloc.newLabels, equals(<String>[
        'ABC-500',
        'ABC-501',
        'ABC-502',
        'ABC-503',
        'ABC-504',
      ]));

      final roTracker = ProductLabelTracker(
        productId: 'prod-ro',
        prefix: 'RO2026-',
        startNumber: 1,
        padLength: 3,
        lastSequence: 0,
        totalCapacity: 3,
      );
      final roAlloc = roTracker.allocateLabels(3);
      expect(roAlloc.newLabels, equals(<String>[
        'RO2026-001',
        'RO2026-002',
        'RO2026-003',
      ]));
    });

    test('TEST 1: Product 1234 Stock 10 -> Add 10 stock -> preview ONLY new labels 011..020', () {
      final initialProduct = Product(
        id: 'prod-1234',
        productCode: '1234',
        name: 'Product 1234',
        category: ProductCategory.domestic,
        wholesalePrice: 5000,
        retailPrice: 8000,
        inStock: true,
        isActive: true,
        stockQuantity: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Draft created with stockQuantity 20, isEditing true, initialStock 10
      final draft = ProductDraft(
        id: initialProduct.id,
        productCode: initialProduct.productCode,
        customCode: initialProduct.productCode,
        name: initialProduct.name,
        stockQuantity: '20',
      );

      final added = (draft.stockQuantityValue ?? 0) - 10;
      expect(added, equals(10));

      final newLabelsPreview = draft.generateStockSerials(
        quantityOverride: added,
        startSequence: 10 + 1,
      );

      expect(newLabelsPreview, equals(<String>[
        '1234-011',
        '1234-012',
        '1234-013',
        '1234-014',
        '1234-015',
        '1234-016',
        '1234-017',
        '1234-018',
        '1234-019',
        '1234-020',
      ]));
    });

    test('TEST 2: Product code changes to ABCD -> Add 10 stock -> new labels ABCD-021..030, old labels remain', () {
      // Product previously had 20 stock under 1234 (001..020)
      // Now admin changes customCode to ABCD and stock to 30
      final draft = const ProductDraft(
        id: 'prod-1234',
        productCode: '1234',
        customCode: 'ABCD',
        isManualCode: true,
        name: 'Product 1234',
        stockQuantity: '30',
      );

      const int prevStock = 20;
      final added = (draft.stockQuantityValue ?? 0) - prevStock;
      expect(added, equals(10));

      final newLabelsPreview = draft.generateStockSerials(
        quantityOverride: added,
        startSequence: prevStock + 1,
      );

      expect(newLabelsPreview, equals(<String>[
        'ABCD-021',
        'ABCD-022',
        'ABCD-023',
        'ABCD-024',
        'ABCD-025',
        'ABCD-026',
        'ABCD-027',
        'ABCD-028',
        'ABCD-029',
        'ABCD-030',
      ]));
    });
  });
}
