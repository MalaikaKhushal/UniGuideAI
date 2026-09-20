import 'package:flutter_test/flutter_test.dart';
import 'package:uniguide_ai/main.dart';

void main() {
  testWidgets('UniGuide AI loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const UniGuideApp());

    expect(find.text('UniGuide AI'), findsWidgets);
  });
}
