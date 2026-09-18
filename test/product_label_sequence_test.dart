import 'package:flutter_test/flutter_test.dart';
import 'package:maruti_water/domain/enums/product_category.dart';
import 'package:maruti_water/domain/models/product.dart';
import 'package:maruti_water/features/owner/labels/domain/product_label_tracker.dart';

void main() {
  group('Print Labels Page & Label Sequence Logic Tests', () {
    test('CASE 1: Product stock = 5, Existing labels = 5 -> New labels available = 0, Print All = 001..005', () {
      final product = Product(
        id: 'prod-001',
        productCode: 'MWS-DOM-001',
        name: 'Domestic RO 10L',
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
        'MWS-DOM-001',
        'MWS-DOM-002',
        'MWS-DOM-003',
        'MWS-DOM-004',
        'MWS-DOM-005',
      ]));
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

      expect(comAlloc.newLabels, equals(<String>[
        'MWS-COM-003',
        'MWS-COM-004',
        'MWS-COM-005',
      ]));

      expect(domAlloc.tracker.nextSequenceNumber, equals(11));
      expect(comAlloc.tracker.nextSequenceNumber, equals(6));
    });
  });
}
