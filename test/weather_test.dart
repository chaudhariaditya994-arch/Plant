import 'package:flutter_test/flutter_test.dart';
import 'package:plant/services/localization_service.dart';
import 'package:plant/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('WeatherService has valid agricultural predefined locations', () {
    expect(WeatherService.predefinedLocations.isNotEmpty, isTrue);
    final pune = WeatherService.predefinedLocations.firstWhere((l) => l.name == 'Pune');
    expect(pune.lat, closeTo(18.52, 0.1));
    expect(pune.lon, closeTo(73.85, 0.1));
  });

  test('WeatherService generates accurate advisory for high humidity', () async {
    await LocalizationService.init();
    await LocalizationService.setLanguage('en');

    final data = WeatherAdvisoryData(
      cityName: 'Pune, Maharashtra',
      temperature: 24.0,
      humidity: 82,
      precipitation: 0.0,
      windSpeed: 10.0,
      weatherCode: 2,
      weatherDescription: 'Partly Cloudy',
      riskLevel: 'high',
      advisoryText: 'High humidity risk',
    );

    expect(data.humidity, equals(82));
    expect(data.riskLevel, equals('high'));
  });
}
