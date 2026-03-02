import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vauge_report/main.dart';

void main() {
  testWidgets('News app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NewsApp());

    // Verify that the app renders without errors.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
