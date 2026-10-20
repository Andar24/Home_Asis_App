import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homeasis_selesai/main.dart';

void main() {
  testWidgets('HomeAsisApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomeAsisApp());

    // Verify that MaterialApp is present.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
