import 'package:flutter_test/flutter_test.dart';
import 'package:maruti_water/domain/enums/user_role.dart';
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
}
