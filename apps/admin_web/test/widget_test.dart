import 'package:ecb_transport_admin/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows Firebase setup guidance when Firebase is unavailable', (tester) async {
    await tester.pumpWidget(const EcbAdminApp(firebaseReady: false));
    expect(find.textContaining('Firebase is not configured.'), findsOneWidget);
  });
}
