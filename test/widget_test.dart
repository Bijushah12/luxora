import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luxora/main.dart';

void main() {
  testWidgets('LUXORA app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const LuxoraApp());
    expect(find.text('LUXORA'), findsOneWidget);
  });
}

