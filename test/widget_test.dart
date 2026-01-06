// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:bahaykusina/main.dart';
import 'package:bahaykusina/providers/auth_provider.dart';

void main() {
  testWidgets('App starts with WelcomeScreen', (WidgetTester tester) async {
    // Create an AuthProvider instance
    final authProvider = AuthProvider();

    // Build our app and trigger a frame.
    await tester.pumpWidget(BahayKusinaApp(authProvider: authProvider));

    // Verify that the WelcomeScreen is shown.
    expect(find.text('BahayKusina'), findsOneWidget);
  });
}
