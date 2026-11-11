import 'package:ecb_transport_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the public welcome screen without Firebase', (tester) async {
    await tester.pumpWidget(const EcbTransportApp(firebaseReady: false));
    await tester.pumpAndSettle();

    expect(find.text('ECB Transport'), findsOneWidget);
    expect(find.textContaining('Continue as guest'), findsOneWidget);
  });
}
