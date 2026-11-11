import 'package:ecb_shared/ecb_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses trusted role claim values', () {
    expect(UserRole.fromClaim('driver'), UserRole.driver);
    expect(UserRole.fromClaim('super_admin'), UserRole.superAdmin);
    expect(UserRole.fromClaim('unknown'), isNull);
  });

  test('only administrator roles can manage transport', () {
    expect(UserRole.transportAdmin.canManageTransport, isTrue);
    expect(UserRole.passenger.canManageTransport, isFalse);
  });
}
