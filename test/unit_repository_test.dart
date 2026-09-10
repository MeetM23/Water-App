import 'package:flutter_test/flutter_test.dart';
import 'package:maruti_water/core/utils/product_code.dart';
import 'package:maruti_water/domain/enums/product_category.dart';
import 'package:maruti_water/domain/models/product_unit.dart';

void main() {
  group('ProductCode Unit Serial Validation', () {
    test('recognises valid physical unit serial numbers (MWS-SN-...)', () {
      expect(ProductCode.isUnitSerial('MWS-SN-DOM-202609-001452-X'), isTrue);
      expect(ProductCode.isUnitSerial('MWS-SN-COM-001234-A'), isTrue);
      expect(ProductCode.isUnitSerial('mws-sn-dom-202609-001452-x'), isTrue);
    });

    test('distinguishes catalogue code from unit serial', () {
      expect(ProductCode.isUnitSerial('MWS-DOM-001042-Z'), isFalse);
      expect(ProductCode.isValid('MWS-DOM-001042-Z'), isTrue);
    });

    test('normalises unit serial inputs correctly', () {
      expect(
        ProductCode.normalise(' mws-sn-dom-202609-001452-x '),
        equals('MWS-SN-DOM-202609-001452-X'),
      );
    });

    test('rejects invalid or garbage inputs', () {
      expect(ProductCode.isUnitSerial('INVALID-SERIAL'), isFalse);
      expect(ProductCode.normalise('INVALID-SERIAL'), isNull);
    });
  });

  group('ProductUnit Model Parsing', () {
    test('parses unregistered unit RPC response correctly', () {
      final json = <String, dynamic>{
        'unit_id': '11111111-1111-1111-1111-111111111111',
        'serial_number': 'MWS-SN-DOM-202609-001452-X',
        'manufactured_at': '2026-09-01T10:00:00Z',
        'product_id': '22222222-2222-2222-2222-222222222222',
        'product_name': 'Maruti Royal RO 12L',
        'model_number': 'ROYAL-12L',
        'category': 'domestic',
        'default_warranty_months': 12,
        'registration': null,
      };

      final unit = ProductUnit.fromJson(json);
      expect(unit.unitId, equals('11111111-1111-1111-1111-111111111111'));
      expect(unit.serialNumber, equals('MWS-SN-DOM-202609-001452-X'));
      expect(unit.productName, equals('Maruti Royal RO 12L'));
      expect(unit.category, equals(ProductCategory.domestic));
      expect(unit.registration, isNull);
    });

    test('parses registered unit RPC response and calculates warranty status', () {
      final json = <String, dynamic>{
        'unit_id': '11111111-1111-1111-1111-111111111111',
        'serial_number': 'MWS-SN-DOM-202609-001452-X',
        'manufactured_at': '2026-09-01T10:00:00Z',
        'product_id': '22222222-2222-2222-2222-222222222222',
        'product_name': 'Maruti Royal RO 12L',
        'model_number': 'ROYAL-12L',
        'category': 'domestic',
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

      final unit = ProductUnit.fromJson(json);
      expect(unit.registration, isNotNull);
      expect(unit.registration!.customerName, equals('Rajesh Patel'));
      expect(unit.registration!.warrantyMonths, equals(12));

      // Active warranty check (2026-01-05 to 2027-01-05 is in future relative to 2026)
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

      final reg = UnitRegistrationInfo.fromJson(json);
      expect(reg.isExpired, isTrue);
    });
  });
}
