import 'package:ecb_transport_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows Firebase setup guidance when configuration is missing', (tester) async {
    await tester.pumpWidget(const EcbTransportApp(firebaseReady: false));
    expect(find.text('ECB Transport'), findsOneWidget);
    expect(find.textContaining('Firebase is not configured'), findsOneWidget);
  });
}
