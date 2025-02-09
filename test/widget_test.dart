import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('MobileApp smoke test', (WidgetTester tester) async {
    // Check if the test is not running on the web.
    if (!kIsWeb) {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MobileApp());

      // Add your test code here. For example:
      // You can check for certain text, interactions, etc.
      expect(find.text('Hello'), findsOneWidget);
      // etc.

    } else {
      // Optionally, skip the test or inform that it's web-only
      print('Skipping mobile app tests because the platform is web');
    }
  });
}
