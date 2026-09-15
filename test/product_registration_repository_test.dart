import 'package:flutter_test/flutter_test.dart';
import 'package:maruti_water/core/utils/product_code.dart';
import 'package:maruti_water/domain/enums/product_category.dart';
import 'package:maruti_water/domain/models/product_lookup.dart';

void main() {
  group('ProductCode Barcode Validation', () {
    test('recognises product barcode numbers (MWS-DOM-...)', () {
      expect(ProductCode.isValid('MWS-DOM-001042-Z'), isTrue);
      expect(ProductCode.isValid('MWS-COM-001234-E'), isTrue);
    });

    test('normalises barcode inputs correctly', () {
      expect(
        ProductCode.normalise(' mws-dom-001042-z '),
        equals('MWS-DOM-001042-Z'),
      );
    });

    test('rejects invalid or garbage inputs', () {
      expect(ProductCode.isValid('INVALID-SERIAL'), isFalse);
      expect(ProductCode.normalise('INVALID-SERIAL'), isNull);
    });
  });

  group('ProductLookup Model Parsing', () {
    test('parses unregistered product RPC response correctly', () {
      final json = <String, dynamic>{
        'unit_id': '22222222-2222-2222-2222-222222222222',
        'product_id': '22222222-2222-2222-2222-222222222222',
        'serial_number': 'MWS-DOM-001042-Z',
        'manufactured_at': '2026-09-01T10:00:00Z',
        'product_name': 'Maruti Royal RO 12L',
        'model_number': 'ROYAL-12L',
        'category': 'domestic',
        'stock_quantity': 15,
        'default_warranty_months': 12,
        'registration': null,
      };

      final unit = ProductLookup.fromJson(json);
      expect(unit.productId, equals('22222222-2222-2222-2222-222222222222'));
      expect(unit.serialNumber, equals('MWS-DOM-001042-Z'));
      expect(unit.productName, equals('Maruti Royal RO 12L'));
      expect(unit.category, equals(ProductCategory.domestic));
      expect(unit.stockQuantity, equals(15));
      expect(unit.registration, isNull);
    });

    test('parses registered product RPC response and calculates warranty status', () {
      final json = <String, dynamic>{
        'unit_id': '22222222-2222-2222-2222-222222222222',
        'product_id': '22222222-2222-2222-2222-222222222222',
        'serial_number': 'MWS-DOM-001042-Z',
        'manufactured_at': '2026-09-01T10:00:00Z',
        'product_name': 'Maruti Royal RO 12L',
        'model_number': 'ROYAL-12L',
        'category': 'domestic',
        'stock_quantity': 15,
        'default_warranty_months': 12,
        'registration': <String, dynamic>{
          'id': '33333333-3333-3333-3333-333333333333',
          'registered_by': '44444444-4444-4444-4444-444444444444',
          'customer_name': 'Rajesh Patel',
          'customer_phone': '+919876543210',
          'customer_city': 'Ahmedabad',
          'customer_address': '123 MG Road',
          'purchase_date': '2026-01-01',
          'installation_date': '2026-01-05',
          'warranty_start_date': '2026-01-05',
          'warranty_months': 12,
          'warranty_end_date': '2027-01-05',
          'invoice_number': 'INV-2026-001',
          'created_at': '2026-01-05T12:00:00Z',
        },
      };

      final unit = ProductLookup.fromJson(json);
      expect(unit.registration, isNotNull);
      expect(unit.registration!.customerName, equals('Rajesh Patel'));
      expect(unit.registration!.warrantyMonths, equals(12));

      // Active warranty check
      expect(unit.registration!.isExpired, isFalse);
    });

    test('detects expired warranty correctly', () {
      final json = <String, dynamic>{
        'id': '33333333-3333-3333-3333-333333333333',
        'customer_name': 'Old Customer',
        'customer_phone': '+919876543210',
        'purchase_date': '2020-01-01',
        'installation_date': '2020-01-05',
        'warranty_start_date': '2020-01-05',
        'warranty_months': 12,
        'warranty_end_date': '2021-01-05',
      };

      final reg = ProductRegistrationInfo.fromJson(json);
      expect(reg.isExpired, isTrue);
    });
  });
}
