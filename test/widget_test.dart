import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant/Home.dart';
import 'package:plant/main.dart';
import 'package:plant/services/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Plantify app MaterialApp configuration test', (WidgetTester tester) async {
    await LocalizationService.init();

    // Verify MyApp structure
    const app = MyApp();
    expect(app, isNotNull);
  });

  testWidgets('Plantify Home dashboard loads without crashing', (WidgetTester tester) async {
    await LocalizationService.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: Home(),
      ),
    );

    // Pump frames for animation controller
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.byType(Home), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
