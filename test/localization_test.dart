import 'package:flutter_test/flutter_test.dart';
import 'package:plant/services/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('LocalizationService switches language correctly', () async {
    await LocalizationService.init();
    expect(LocalizationService.currentLanguage, equals('en'));

    // Switch to Marathi
    await LocalizationService.setLanguage('mr');
    expect(LocalizationService.currentLanguage, equals('mr'));
    expect(LocalizationService.tr('app_name'), equals('प्लॅन्टिफाय'));
    expect(LocalizationService.tr('camera'), equals('कॅमेरा'));

    // Switch to Hindi
    await LocalizationService.setLanguage('hi');
    expect(LocalizationService.currentLanguage, equals('hi'));
    expect(LocalizationService.tr('app_name'), equals('प्लांटिफाय'));
    expect(LocalizationService.tr('camera'), equals('कैमरा'));

    // Switch back to English
    await LocalizationService.setLanguage('en');
    expect(LocalizationService.currentLanguage, equals('en'));
    expect(LocalizationService.tr('app_name'), equals('Plantify'));
    expect(LocalizationService.tr('camera'), equals('Camera'));
  });

  test('LocalizationService falls back to English for unknown keys', () async {
    await LocalizationService.setLanguage('mr');
    expect(LocalizationService.tr('non_existent_key_123'), equals('non_existent_key_123'));
  });
}
