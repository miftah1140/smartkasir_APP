// Smoke test untuk SmartKasir app
import 'package:flutter_test/flutter_test.dart';
import 'package:smartkasir_app/main.dart';

void main() {
  testWidgets('SmartKasir app smoke test', (WidgetTester tester) async {
    // Build app dan trigger frame pertama
    await tester.pumpWidget(const SmartKasirApp());

    // Verifikasi splash screen tampil
    expect(find.text('SmartKasir'), findsOneWidget);
  });
}
