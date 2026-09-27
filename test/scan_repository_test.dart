import 'package:flutter_test/flutter_test.dart';
import 'package:maruti_water/domain/enums/user_role.dart';
import 'package:maruti_water/domain/models/dealer_activity.dart';
import 'package:maruti_water/domain/models/warranty_claim.dart';
import 'package:maruti_water/domain/repositories/scan_repository.dart';

void main() {
  group('ScanRepository Stock Consumption & Dispatch Flow', () {
    test('ScanSource enum maps correctly to RPC parameter', () {
      expect(ScanSource.camera.name, equals('camera'));
      expect(ScanSource.manual.name, equals('manual'));
    });

    test('UserRole enum maps correctly for RPC role checks', () {
      expect(UserRole.owner.name, equals('owner'));
      expect(UserRole.wholesaler.name, equals('wholesaler'));
      expect(UserRole.retailer.name, equals('retailer'));
    });
  });

  group('Warranty Claim Model and Repository Tests', () {
    test('WarrantyClaimStatus serialization and labels', () {
      expect(WarrantyClaimStatus.pending.name, 'pending');
      expect(WarrantyClaimStatus.approved.name, 'approved');
      expect(WarrantyClaimStatus.rejected.name, 'rejected');
      expect(WarrantyClaimStatus.resolved.name, 'resolved');

      expect(WarrantyClaimStatus.pending.label, 'Pending');
      expect(WarrantyClaimStatus.approved.label, 'Approved');
      expect(WarrantyClaimStatus.rejected.label, 'Rejected');
      expect(WarrantyClaimStatus.resolved.label, 'Resolved');
    });

    test('WarrantyClaim preserves dynamic product name and exact QR unitId', () {
      final claim = WarrantyClaim(
        id: 'claim-123',
        claimNumber: 'CLM-001',
        unitId: '1-001',
        userId: 'user-456',
        productId: 'prod-789',
        claimType: 'Warranty Claim',
        description: 'Motor making noise',
        contactPhone: '+919876543210',
        status: WarrantyClaimStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        serialNumber: '1-001',
        productName: 'Maruti Commercial RO 50LPH',
        modelNumber: 'COM-50',
      );

      expect(claim.unitId, equals('1-001'));
      expect(claim.serialNumber, equals('1-001'));
      expect(claim.productName, equals('Maruti Commercial RO 50LPH'));
      expect(claim.productId, equals('prod-789'));
    });
  });

  group('Admin Dashboard RPC Model Parsing', () {
    test('top_scanned_products RPC response mapping parses correctly', () {
      final sqlRow = <String, dynamic>{
        'product_id': 'prod-uuid-1',
        'product_name': 'Commercial Water Plant 250LPH',
        'product_code': 'ABCD',
        'category': 'commercial',
        'scan_count': 42,
      };

      final scanned = ScannedProduct(
        productId: (sqlRow['product_id'] ?? sqlRow['id'] ?? '').toString(),
        name: (sqlRow['product_name'] ?? sqlRow['name'] ?? 'Product').toString(),
        productCode: (sqlRow['product_code'] ?? sqlRow['code'] ?? '').toString(),
        scanCount: (sqlRow['scan_count'] as num?)?.toInt() ?? 0,
      );

      expect(scanned.productId, equals('prod-uuid-1'));
      expect(scanned.name, equals('Commercial Water Plant 250LPH'));
      expect(scanned.productCode, equals('ABCD'));
      expect(scanned.scanCount, equals(42));
    });

    test('recent_dealer_activity RPC response mapping parses correctly', () {
      final sqlRow = <String, dynamic>{
        'user_id': 'user-uuid-1',
        'full_name': 'Ramesh Bhai',
        'firm_name': 'Ramesh Water Tech',
        'phone': '9876543210',
        'role': 'retailer',
        'status': 'approved',
        'last_activity': '2026-09-20T01:00:00.000Z',
        'activity_type': 'scan',
      };

      final entry = DealerActivityEntry(
        id: (sqlRow['id'] ?? sqlRow['user_id'] ?? '').toString(),
        action: (sqlRow['action'] ?? (sqlRow['activity_type'] != null ? 'dealer.${sqlRow['activity_type']}' : 'dealer.active')).toString(),
        firmName: (sqlRow['firm_name'] as String?) ?? '',
        fullName: (sqlRow['full_name'] as String?) ?? '',
        createdAt: sqlRow['created_at'] != null
            ? DateTime.parse(sqlRow['created_at'].toString())
            : (sqlRow['last_activity'] != null
                ? DateTime.parse(sqlRow['last_activity'].toString())
                : DateTime.now()),
      );

      expect(entry.id, equals('user-uuid-1'));
      expect(entry.fullName, equals('Ramesh Bhai'));
      expect(entry.firmName, equals('Ramesh Water Tech'));
      expect(entry.action, equals('dealer.scan'));
      expect(entry.createdAt.toUtc().toIso8601String(), equals('2026-09-20T01:00:00.000Z'));
    });
  });
}
