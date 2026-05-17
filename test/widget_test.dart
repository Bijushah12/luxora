import 'package:flutter_test/flutter_test.dart';
import 'package:luxora/main.dart';
import 'package:luxora/providers/theme_provider.dart';

void main() {
  testWidgets('LUXORA app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(LuxoraApp(themeProvider: ThemeProvider()));
    expect(find.text('LUXORA'), findsOneWidget);
  });
}
