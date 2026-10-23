import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plant/services/localization_service.dart';

class WeatherLocation {
  final String name;
  final String state;
  final double lat;
  final double lon;

  const WeatherLocation({
    required this.name,
    required this.state,
    required this.lat,
    required this.lon,
  });
}

class WeatherAdvisoryData {
  final String cityName;
  final double temperature;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final int weatherCode;
  final String weatherDescription;
  final String riskLevel; // 'low', 'moderate', 'high'
  final String advisoryText;

  WeatherAdvisoryData({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
    required this.weatherDescription,
    required this.riskLevel,
    required this.advisoryText,
  });
}

class WeatherService {
  static const List<WeatherLocation> predefinedLocations = [
    WeatherLocation(
      name: 'Pune',
      state: 'Maharashtra',
      lat: 18.5204,
      lon: 73.8567,
    ),
    WeatherLocation(
      name: 'Nashik',
      state: 'Maharashtra',
      lat: 19.9975,
      lon: 73.7898,
    ),
    WeatherLocation(
      name: 'Nagpur',
      state: 'Maharashtra',
      lat: 21.1458,
      lon: 79.0882,
    ),
    WeatherLocation(
      name: 'New Delhi',
      state: 'Delhi',
      lat: 28.6139,
      lon: 77.2090,
    ),
    WeatherLocation(
      name: 'Lucknow',
      state: 'Uttar Pradesh',
      lat: 26.8467,
      lon: 80.9462,
    ),
    WeatherLocation(
      name: 'Hyderabad',
      state: 'Telangana',
      lat: 17.3850,
      lon: 78.4867,
    ),
    WeatherLocation(
      name: 'Bengaluru',
      state: 'Karnataka',
      lat: 12.9716,
      lon: 77.5946,
    ),
  ];

  static WeatherLocation selectedLocation = predefinedLocations[0];

  static Future<WeatherAdvisoryData> fetchWeather([WeatherLocation? location]) async {
    final loc = location ?? selectedLocation;
    selectedLocation = loc;

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${loc.lat}&longitude=${loc.lon}&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];

        final double temp = (current['temperature_2m'] as num).toDouble();
        final int humidity = (current['relative_humidity_2m'] as num).toInt();
        final double precip = (current['precipitation'] as num).toDouble();
        final double wind = (current['wind_speed_10m'] as num).toDouble();
        final int code = (current['weather_code'] as num).toInt();

        final desc = _getWeatherDescription(code);
        final riskAndAdvisory = _generateAgriculturalAdvisory(temp, humidity, precip, wind);

        return WeatherAdvisoryData(
          cityName: '${loc.name}, ${loc.state}',
          temperature: temp,
          humidity: humidity,
          precipitation: precip,
          windSpeed: wind,
          weatherCode: code,
          weatherDescription: desc,
          riskLevel: riskAndAdvisory['risk']!,
          advisoryText: riskAndAdvisory['advisory']!,
        );
      }
    } catch (e) {
      // Fallback data when network is unavailable
    }

    return _getFallbackData(loc);
  }

  static String _getWeatherDescription(int code) {
    if (code == 0) return 'Clear Sky';
    if (code >= 1 && code <= 3) return 'Partly Cloudy';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 67) return 'Rain / Drizzle';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Cloudy';
  }

  static Map<String, String> _generateAgriculturalAdvisory(
    double temp,
    int humidity,
    double precip,
    double wind,
  ) {
    final lang = LocalizationService.currentLanguage;

    if (humidity >= 75 && temp >= 18 && temp <= 32) {
      if (lang == 'mr') {
        return {
          'risk': 'high',
          'advisory':
              'जास्त आर्द्रता ($humidity%) आणि मध्यम तापमान ($temp°C) मुळे पिकांवर करपा (Blight) आणि बुरशीजन्य रोगांचा प्रादुर्भाव वाढू शकतो. ट्रायकोडर्मा किंवा शिफारशीत बुरशीनाशकाची फवारणी करा.',
        };
      } else if (lang == 'hi') {
        return {
          'risk': 'high',
          'advisory':
              'अत्यधिक नमी ($humidity%) और अनुकूल तापमान ($temp°C) के कारण झुलसा व फफूंद जनित रोगों का खतरा अधिक है। खेत में जलभराव न होने दें और उपयुक्त फफूंदनाशक का छिड़काव करें।',
        };
      } else {
        return {
          'risk': 'high',
          'advisory':
              'High humidity ($humidity%) and warm temperature ($temp°C) create peak conditions for fungal infections (early/late blight, mildew). Inspect leaf undersides and ensure field drainage.',
        };
      }
    }

    if (precip > 5.0) {
      if (lang == 'mr') {
        return {
          'risk': 'moderate',
          'advisory':
              'सध्या पाऊस सुरू आहे. खत व कीटकनाशक फवारणी पुढे ढकला. शेतात पाण्याचा निचरा योग्य राहील याची दक्षता घ्या.',
        };
      } else if (lang == 'hi') {
        return {
          'risk': 'moderate',
          'advisory':
              'बारिश होने की संभावना है। अभी रासायनिक छिड़काव या यूरिया डालने से बचें। जल निकासी की व्यवस्था सुनिश्चित करें।',
        };
      } else {
        return {
          'risk': 'moderate',
          'advisory':
              'Rain detected ($precip mm). Postpone chemical sprays to prevent wash-off. Ensure adequate furrow drainage to prevent root rot.',
        };
      }
    }

    if (temp >= 36) {
      if (lang == 'mr') {
        return {
          'risk': 'moderate',
          'advisory':
              'जास्त उष्णतेमुळे ($temp°C) पिकांना पाण्याचा ताण पडू शकतो. सकाळच्या किंवा संध्याकाळच्या वेळेस हलके पाणी द्या आणि आच्छादनाचा (Mulching) वापर करा.',
        };
      } else if (lang == 'hi') {
        return {
          'risk': 'moderate',
          'advisory':
              'तीव्र तापमान ($temp°C) के कारण नमी तेजी से उड़ रही है। सुबह या शाम को हल्की सिंचाई करें एवं मल्चिंग अपनाएं।',
        };
      } else {
        return {
          'risk': 'moderate',
          'advisory':
              'High heat ($temp°C) detected. Irrigate during early morning or evening hours to reduce evapotranspiration and leaf scorch.',
        };
      }
    }

    if (lang == 'mr') {
      return {
        'risk': 'low',
        'advisory':
            'हवामान शेतीकामांसाठी अनुकूल आहे. तापमान: $temp°C, आर्द्रता: $humidity%. आंतरमशागत व खत व्यवस्थापन सुरळीतपणे करू शकता.',
      };
    } else if (lang == 'hi') {
      return {
        'risk': 'low',
        'advisory':
            'मौसम खेती के अनुकूल है। तापमान: $temp°C, नमी: $humidity%। नियमित निराई-गुड़ाई और पोषण प्रबंधन जारी रखें।',
      };
    } else {
      return {
        'risk': 'low',
        'advisory':
            'Favorable agricultural weather. Temperature: $temp°C, Humidity: $humidity%. Suitable for routine cultural practices and weeding.',
      };
    }
  }

  static WeatherAdvisoryData _getFallbackData(WeatherLocation loc) {
    final lang = LocalizationService.currentLanguage;
    String defaultAdv = 'Weather conditions normal for seasonal crops. Maintain recommended irrigation schedule.';
    if (lang == 'mr') {
      defaultAdv = 'हवामान पिकांसाठी सामान्य आहे. नियमित सिंचन व पीक तपासणी सुरू ठेवावी.';
    } else if (lang == 'hi') {
      defaultAdv = 'फसलों के लिए मौसम सामान्य है। अनुशंसित सिंचाई समय-सारणी का पालन करें।';
    }

    return WeatherAdvisoryData(
      cityName: '${loc.name}, ${loc.state}',
      temperature: 28.0,
      humidity: 65,
      precipitation: 0.0,
      windSpeed: 8.5,
      weatherCode: 1,
      weatherDescription: 'Partly Cloudy',
      riskLevel: 'low',
      advisoryText: defaultAdv,
    );
  }
}
