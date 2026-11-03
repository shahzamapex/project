import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('InteriorCraftApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InteriorCraftApp());
    expect(find.byType(InteriorCraftApp), findsOneWidget);
  });
}
