import 'package:flutter_test/flutter_test.dart';
import 'package:life_item/main.dart';

void main() {
  testWidgets('LifeItem app berjalan', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeItemApp());

    expect(find.text('LifeItem'), findsOneWidget);
    expect(find.text('Recent Items'), findsOneWidget);
  });
}