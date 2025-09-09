// This is a basic Flutter widget test for Raqim app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raqim/main.dart';

void main() {
  testWidgets('Raqim app builds without errors', (WidgetTester tester) async {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(RaqimApp(prefs: prefs));
    
    // Verify that the app widget exists
    expect(find.byType(RaqimApp), findsOneWidget);
    
    // Verify MaterialApp is created
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}