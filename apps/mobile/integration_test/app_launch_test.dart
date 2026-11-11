import 'package:ecb_transport_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mobile app displays setup state without Firebase configuration', (tester) async {
    await tester.pumpWidget(const EcbTransportApp(firebaseReady: false));
    await tester.pumpAndSettle();
    expect(find.text('ECB Transport'), findsOneWidget);
    expect(find.textContaining('Firebase is not configured'), findsOneWidget);
  });
}
