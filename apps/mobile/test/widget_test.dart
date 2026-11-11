import 'package:ecb_transport_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the welcome screen when Firebase is unavailable', (tester) async {
    await tester.pumpWidget(const EcbTransportApp(firebaseReady: false));
    await tester.pumpAndSettle();

    expect(find.text('ECB Transport'), findsOneWidget);
    expect(find.text('Public transport, connected.'), findsOneWidget);
    expect(find.textContaining('Firebase is not configured'), findsOneWidget);
  });
}
