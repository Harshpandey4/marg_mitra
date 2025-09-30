import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marg_mitra/main.dart';

void main() {
  testWidgets('App loads and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MargMitraApp());

    // Wait for any async operations
    await tester.pumpAndSettle();

    // Verify that our app loads successfully
    // You can add more specific tests based on what your splash screen shows
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}