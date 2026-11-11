import 'package:ecb_shared/ecb_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts only ADMIN and USER role claims', () {
    expect(UserRole.fromClaim('admin'), UserRole.admin);
    expect(UserRole.fromClaim('user'), UserRole.user);
    expect(UserRole.fromClaim('driver'), isNull);
    expect(UserRole.fromClaim('passenger'), isNull);
    expect(UserRole.fromClaim('transport_admin'), isNull);
    expect(UserRole.fromClaim('super_admin'), isNull);
    expect(UserRole.fromClaim('unknown'), isNull);
  });

  test('only ADMIN can manage transport', () {
    expect(UserRole.admin.canManageTransport, isTrue);
    expect(UserRole.user.canManageTransport, isFalse);
  });
}
