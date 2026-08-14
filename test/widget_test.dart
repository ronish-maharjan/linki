import 'package:flutter_test/flutter_test.dart';

import 'package:linki/app/app.dart';

void main() {
  testWidgets('Linki app starts', (tester) async {
    await tester.pumpWidget(const LinkiApp());

    expect(find.text('RSS'), findsOneWidget);
    expect(find.text('BOOKMARKS'), findsOneWidget);
  });
}
