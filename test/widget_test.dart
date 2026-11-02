import 'package:flutter_test/flutter_test.dart';

import 'package:jinzhao/main.dart';

void main() {
  testWidgets('App launches and shows home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const JinzhaoApp());
    await tester.pumpAndSettle();
    expect(find.text('诗词'), findsOneWidget);
  });
}
