// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:attendy/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AttendyApp());

    // Verify the app title is displayed
    expect(find.text('Attendy'), findsOneWidget);
  });
}
