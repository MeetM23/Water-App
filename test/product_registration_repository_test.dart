import 'package:flutter_test/flutter_test.dart';
import 'package:maruti_water/core/utils/product_code.dart';
import 'package:maruti_water/domain/enums/product_category.dart';
import 'package:maruti_water/domain/models/catalog_product.dart';
import 'package:maruti_water/domain/models/product_lookup.dart';

void main() {
  group('ProductCode Barcode Validation', () {
    test('recognises arbitrary product code and label patterns', () {
      expect(ProductCode.isValid('MWS-DOM-001'), isTrue);
      expect(ProductCode.isValid('MWS-COM-100'), isTrue);
      expect(ProductCode.isValid('ABC-500'), isTrue);
      expect(ProductCode.isValid('RO2026-001'), isTrue);
      expect(ProductCode.isValid('MARUTI-X-0001'), isTrue);
      expect(ProductCode.isValid('PRODUCT-A-25'), isTrue);
      expect(ProductCode.isValid('MWS-DOM-001042-Z'), isTrue);
    });

    test('normalises barcode inputs correctly', () {
      expect(ProductCode.normalise(' mws-dom-001 '), equals('MWS-DOM-001'));
      expect(ProductCode.normalise(' abc-500 '), equals('ABC-500'));
      expect(
        ProductCode.normalise(' mws-dom-001042-z '),
        equals('MWS-DOM-001042-Z'),
      );
    });

    test('rejects invalid or garbage inputs', () {
      expect(ProductCode.isValid('INVALID #@\$ SERIAL'), isFalse);
      expect(ProductCode.isValid(''), isFalse);
      expect(ProductCode.normalise('INVALID #@\$ SERIAL'), isNull);
      expect(ProductCode.normalise(''), isNull);
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

    test('verifies label 001 registered does NOT mark label 002 registered for same product', () {
      final label1Json = <String, dynamic>{
        'unit_id': 'MWS-COM-001013-Q-001',
        'product_id': 'prod-uuid-1013',
        'serial_number': 'MWS-COM-001013-Q-001',
        'product_name': 'Commercial RO 50L',
        'product_code': 'MWS-COM-001013-Q',
        'category': 'commercial',
        'manufactured_at': '2026-09-01T10:00:00Z',
        'status': 'registered',
        'stock_quantity': 4,
        'registration': <String, dynamic>{
          'id': 'reg-001',
          'customer_name': 'First Customer',
          'warranty_months': 12,
          'purchase_date': '2026-01-01',
          'installation_date': '2026-01-05',
          'warranty_start_date': '2026-01-05',
          'warranty_end_date': '2027-01-05',
        },
      };

      final label2Json = <String, dynamic>{
        'unit_id': 'MWS-COM-001013-Q-002',
        'product_id': 'prod-uuid-1013', // Same product UUID
        'serial_number': 'MWS-COM-001013-Q-002',
        'product_name': 'Commercial RO 50L',
        'product_code': 'MWS-COM-001013-Q',
        'category': 'commercial',
        'manufactured_at': '2026-09-01T10:00:00Z',
        'status': 'available',
        'stock_quantity': 4,
        'registration': null, // Label 002 is available/unregistered!
      };

      final unit1 = ProductLookup.fromJson(label1Json);
      final unit2 = ProductLookup.fromJson(label2Json);

      // Both belong to same product
      expect(unit1.productId, equals(unit2.productId));
      expect(unit1.productCode, equals(unit2.productCode));

      // Independent states: Label 1 is registered, Label 2 is NOT registered
      expect(unit1.registration, isNotNull);
      expect(unit1.status, equals('registered'));

      expect(unit2.registration, isNull);
      expect(unit2.status, equals('available'));
    });

    test('TEST 3 & TEST 4: Scanned exact QR resolves product information without loose matching', () {
      final json = <String, dynamic>{
        'unit_id': 'ABCD-021',
        'product_id': 'prod-uuid-1234',
        'serial_number': 'ABCD-021',
        'manufactured_at': '2026-09-01T10:00:00Z',
        'product_name': 'Commercial Water Plant 250LPH',
        'product_code': 'ABCD',
        'model_number': 'WP-250',
        'category': 'commercial',
        'default_warranty_months': 24,
        'stock_quantity': 18,
        'registration': null,
      };

      final unit = ProductLookup.fromJson(json);
      expect(unit.productId, equals('prod-uuid-1234'));
      expect(unit.productCode, equals('ABCD'));
      expect(unit.productName, equals('Commercial Water Plant 250LPH'));
      expect(unit.modelNumber, equals('WP-250'));
      expect(unit.category, equals(ProductCategory.commercial));
      expect(unit.defaultWarrantyMonths, equals(24));
    });

    test('TEST 5: Arbitrary random code (e.g. u655fog;hofds) rejects invalid input or matches no product', () {
      // Normalisation of garbage with special characters returns null or cleans
      expect(ProductCode.isValid('u655fog;hofds'), isFalse);
    });

    test('TEST 7: catalog_view JSON with primary_image_path is parsed correctly by CatalogProduct', () {
      final catalogJson = <String, dynamic>{
        'id': 'prod-uuid-999',
        'product_code': 'MWS-DOM-001',
        'name': 'Maruti Domestic RO',
        'category': 'domestic',
        'price': 6500.0,
        'wholesale_price': 5000.0,
        'retail_price': 6500.0,
        'in_stock': true,
        'is_active': true,
        'primary_image_path': 'prod-uuid-999/primary.jpg',
      };

      final catalogProduct = CatalogProduct.fromJson(catalogJson);
      expect(catalogProduct.id, equals('prod-uuid-999'));
      expect(catalogProduct.productCode, equals('MWS-DOM-001'));
      expect(catalogProduct.price, equals(6500.0));
      expect(catalogProduct.primaryImagePath, equals('prod-uuid-999/primary.jpg'));
    });
  });
}
