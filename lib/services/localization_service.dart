import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _prefKey = 'app_language';
  static String _currentLanguage = 'en';

  static final ValueNotifier<String> languageNotifier =
      ValueNotifier<String>('en');

  static String get currentLanguage => _currentLanguage;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_prefKey) ?? 'en';
    languageNotifier.value = _currentLanguage;
  }

  static Future<void> setLanguage(String langCode) async {
    if (!['en', 'mr', 'hi'].contains(langCode)) return;
    _currentLanguage = langCode;
    languageNotifier.value = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, langCode);
  }

  static String tr(String key) {
    final langMap = _localizedValues[_currentLanguage] ?? _localizedValues['en']!;
    return langMap[key] ?? _localizedValues['en']?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App & Navigation
      'app_name': 'Plantify',
      'app_tagline': 'AI Smart Agriculture Assistant',
      'nav_home': 'Home',
      'nav_chat': 'Chat',
      'nav_camera': 'Scan',
      'nav_history': 'History',
      'nav_profile': 'Profile',
      'nav_settings': 'Settings',

      // Home Screen
      'greeting_title': 'Ai Plant Care',
      'what_we_offer': 'What we offer?',
      'card1_first': 'Scan & Detect',
      'card1_second': 'Diseases',
      'card1_desc':
          'Upload or capture leaf photos for instant diagnosis and confidence score.',
      'card2_first': 'Weather & Crop',
      'card2_second': 'Advisory',
      'card2_desc':
          'Real-time weather insights, disease risk warnings, and farming tips.',
      'card3_first': 'AI Krishi',
      'card3_second': 'Chatbot',
      'card3_desc':
          'Ask Gemini expert questions about crop care, fertilizers, and pest control.',

      // Weather widget
      'weather_advisory': 'Agricultural Weather Advisory',
      'weather_loading': 'Loading local weather data...',
      'temp_label': 'Temp',
      'humidity_label': 'Humidity',
      'rain_label': 'Rain Chance',
      'wind_label': 'Wind',
      'risk_high': 'High Disease Risk',
      'risk_moderate': 'Moderate Risk',
      'risk_low': 'Low Disease Risk',
      'change_city': 'Change Location',

      // Dialogs & Actions
      'camera': 'Camera',
      'gallery': 'Gallery',
      'take_photo': 'Take Photo',
      'pick_gallery': 'Choose from Gallery',
      'processing_image': 'Analyzing leaf with AI...',
      'not_plant_error':
          'The uploaded image does not appear to be a plant leaf. Please provide a clear, close-up photo of the affected leaf.',
      'low_confidence_error':
          'Diagnosis confidence is low. Please capture a well-lit, steady, and clear close-up of the leaf surface.',
      'retry': 'Try Again',
      'cancel': 'Cancel',
      'close': 'Close',
      'delete': 'Delete',
      'more_info': 'More info',
      'ask_chatbot': 'Ask AI Chatbot',
      'sources': 'Reliable Agricultural Sources',
      'symptoms': 'Symptoms',
      'management': 'Treatment & Management',
      'organic_management': 'Organic & Cultural Control',
      'chemical_management': 'Recommended Chemical Treatment',
      'confidence': 'Confidence Score',
      'reliable_diagnosis': 'Reliable Diagnosis',
      'unverified_diagnosis': 'Low Confidence Diagnosis',

      // Chat Screen
      'chat_title': 'Krishi AI Chatbot',
      'chat_hint': 'Ask about crop care, diseases, fertilizers...',
      'chat_greeting':
          'Namaste! I am your AI Agriculture Assistant powered by Gemini. How can I help with your crops today?',
      'chat_thinking': 'Consulting agricultural database...',
      'chat_error':
          'Could not get a response. Please check your internet connection or Gemini API key.',
      'quick_tomato': 'Tomato leaf curling & spots',
      'quick_fertilizer': 'Organic fertilizer dosage',
      'quick_fungal': 'Prevent fungal blight in humid weather',
      'quick_weather': 'Weather precautions for my crops',

      // History Screen
      'history_title': 'Diagnosis History',
      'history_empty': 'No scan history recorded yet.',
      'history_empty_sub': 'Scan a plant leaf to see your diagnostic history here.',
      'delete_scan_confirm': 'Are you sure you want to delete this scan record?',

      // Settings Screen
      'settings_title': 'Settings',
      'language_setting': 'App Language / भाषा',
      'gemini_api_key': 'Gemini API Key',
      'enter_api_key': 'Enter Gemini API Key',
      'api_key_saved': 'Gemini API key saved successfully!',
      'about_app': 'About Plantify AI',
      'privacy_policy': 'Privacy Policy',
    },
    'mr': {
      // App & Navigation
      'app_name': 'प्लॅन्टिफाय',
      'app_tagline': 'एआय स्मार्ट कृषी सहाय्यक',
      'nav_home': 'मुख्यपृष्ठ',
      'nav_chat': 'चर्चा',
      'nav_camera': 'तपासा',
      'nav_history': 'इतिहास',
      'nav_profile': 'प्रोफाइल',
      'nav_settings': 'सेटिंग्ज',

      // Home Screen
      'greeting_title': 'एआय पीक संरक्षण',
      'what_we_offer': 'आमच्या सेवा',
      'card1_first': 'रोग निदान व',
      'card1_second': 'तपासणी',
      'card1_desc':
          'पानाचे छायाचित्र काढून किंवा अपलोड करून तात्काळ अचूक रोग निदान मिळवा.',
      'card2_first': 'हवामान व पीक',
      'card2_second': 'सल्लागार',
      'card2_desc':
          'थेट हवामान अंदाज, पीक रोगाचा संभाव्य धोका व योग्य शेती सल्ला.',
      'card3_first': 'एआय कृषी',
      'card3_second': 'चॅटबॉट',
      'card3_desc':
          'खत व्यवस्थापन, किड नियंत्रण व पीक संरक्षणासाठी जेमिनीला थेट प्रश्न विचारा.',

      // Weather widget
      'weather_advisory': 'हवामान आधारित कृषी सल्ला',
      'weather_loading': 'स्थानिक हवामान माहिती लोड होत आहे...',
      'temp_label': 'तापमान',
      'humidity_label': 'आर्द्रता',
      'rain_label': 'पाऊस शक्यता',
      'wind_label': 'वारा',
      'risk_high': 'रोगाचा जास्त धोका',
      'risk_moderate': 'मध्यम धोका',
      'risk_low': 'कमी धोका',
      'change_city': 'ठिकाण बदला',

      // Dialogs & Actions
      'camera': 'कॅमेरा',
      'gallery': 'गॅलरी',
      'take_photo': 'फोटो काढा',
      'pick_gallery': 'गॅलरीतून निवडा',
      'processing_image': 'एआय द्वारे पानाचे विश्लेषण सुरू आहे...',
      'not_plant_error':
          'अपलोड केलेला फोटो वनस्पती पानाचा दिसत नाही. कृपया रोगाची लक्षणे स्पष्ट दिसणारा पानाचा फोटो घ्या.',
      'low_confidence_error':
          'निदान अचूकतेची खात्री कमी आहे. कृपया चांगल्या प्रकाशात पानाचा स्पष्ट व जवळून फोटो काढा.',
      'retry': 'पुन्हा प्रयत्न करा',
      'cancel': 'रद्द करा',
      'close': 'बंद करा',
      'delete': 'हटवा',
      'more_info': 'अधिक माहिती',
      'ask_chatbot': 'एआय सहाय्यकाला विचारा',
      'sources': 'अधिकृत कृषी संदर्भ व स्त्रोत',
      'symptoms': 'रोगाची लक्षणे',
      'management': 'उपाययोजना व नियंत्रण',
      'organic_management': 'सेंद्रिय व मशागतीचे उपाय',
      'chemical_management': 'शिफारस केलेले रासायनिक उपाय',
      'confidence': 'अचूकता गुण (Confidence)',
      'reliable_diagnosis': 'खात्रीशीर निदान',
      'unverified_diagnosis': 'कमी खात्री असलेले निदान',

      // Chat Screen
      'chat_title': 'कृषी एआय चॅटबॉट',
      'chat_hint': 'पीक संरक्षण, खते, रोग याविषयी विचारा...',
      'chat_greeting':
          'नमस्कार शेतकरी बंधूंनो! मी तुमचा जेमिनी-आधारित कृषी सहाय्यक आहे. आज मी आपल्या पिकांसाठी कशी मदत करू?',
      'chat_thinking': 'कृषी माहिती शोधत आहे...',
      'chat_error':
          'प्रतिसाद मिळवण्यात अडचण आली. कृपया इंटरनेट किंवा जेमिनी एपीआय की तपासा.',
      'quick_tomato': 'टोमॅटोवरील करपा व डाग नियंत्रण',
      'quick_fertilizer': 'सेंद्रिय खताचे योग्य प्रमाण',
      'quick_fungal': 'दमट हवेत बुरशीजन्य रोग प्रतिबंध',
      'quick_weather': 'हवामानानुसार पिकांची काळजी',

      // History Screen
      'history_title': 'तपासणी इतिहास',
      'history_empty': 'अद्याप कोणताही तपासणी इतिहास नाही.',
      'history_empty_sub': 'आपल्या वनस्पतीचे पान स्कॅन करा आणि येथे इतिहास पहा.',
      'delete_scan_confirm': 'तुम्हाला ही तपासणी नोंद नक्की हटवायची आहे का?',

      // Settings Screen
      'settings_title': 'सेटिंग्ज',
      'language_setting': 'अ‍ॅप भाषा / Language',
      'gemini_api_key': 'जेमिनी API Key',
      'enter_api_key': 'जेमिनी API Key प्रविष्ट करा',
      'api_key_saved': 'जेमिनी API की यशस्वीरित्या सेव्ह झाली!',
      'about_app': 'प्लॅन्टिफाय एआय बद्दल',
      'privacy_policy': 'गोपनीयता धोरण',
    },
    'hi': {
      // App & Navigation
      'app_name': 'प्लांटिफाय',
      'app_tagline': 'एआई स्मार्ट कृषि सहायक',
      'nav_home': 'होम',
      'nav_chat': 'चैट',
      'nav_camera': 'स्कैन',
      'nav_history': 'इतिहास',
      'nav_profile': 'प्रोफ़ाइल',
      'nav_settings': 'सेटिंग्स',

      // Home Screen
      'greeting_title': 'एआई पौधा संरक्षण',
      'what_we_offer': 'हमारी सेवाएं',
      'card1_first': 'रोग पहचान व',
      'card1_second': 'निदान',
      'card1_desc':
          'पत्ती की फोटो खींचें या अपलोड करें और तुरंत सटीक रोग निदान प्राप्त करें।',
      'card2_first': 'मौसम व फसल',
      'card2_second': 'सलाह',
      'card2_desc':
          'लाइव मौसम अपडेट, बीमारी का जोखिम अलर्ट और वैज्ञानिक कृषि परामर्श।',
      'card3_first': 'एआई कृषि',
      'card3_second': 'चैटबॉट',
      'card3_desc':
          'खाद, कीटनाशक और फसल देखभाल पर जेमिनी एआई से सीधे सवाल पूछें।',

      // Weather widget
      'weather_advisory': 'मौसम आधारित फसल सलाह',
      'weather_loading': 'स्थानीय मौसम की जानकारी लोड हो रही है...',
      'temp_label': 'तापमान',
      'humidity_label': 'नमी',
      'rain_label': 'बारिश की संभावना',
      'wind_label': 'हवा की गति',
      'risk_high': 'रोग का उच्च जोखिम',
      'risk_moderate': 'मध्यम जोखिम',
      'risk_low': 'कम जोखिम',
      'change_city': 'स्थान बदलें',

      // Dialogs & Actions
      'camera': 'कैमरा',
      'gallery': 'गैलरी',
      'take_photo': 'फोटो खींचें',
      'pick_gallery': 'गैलरी से चुनें',
      'processing_image': 'एआई द्वारा पत्ती का विश्लेषण जारी है...',
      'not_plant_error':
          'अपलोड की गई तस्वीर पौधे की पत्ती नहीं लग रही है। कृपया पत्ती की स्पष्ट और पास की तस्वीर लें।',
      'low_confidence_error':
          'निदान की सटीकता कम है। कृपया पर्याप्त रोशनी में पत्ती की स्पष्ट और स्थिर फोटो लें।',
      'retry': 'पुनः प्रयास करें',
      'cancel': 'रद्द करें',
      'close': 'बंद करें',
      'delete': 'हटाएं',
      'more_info': 'अधिक जानकारी',
      'ask_chatbot': 'एआई सहायक से पूछें',
      'sources': 'प्रामाणिक कृषि संदर्भ व स्रोत',
      'symptoms': 'रोग के लक्षण',
      'management': 'उपचार एवं नियंत्रण',
      'organic_management': 'जैविक एवं देशी उपाय',
      'chemical_management': 'अनुशंसित रासायनिक उपचार',
      'confidence': 'सटीकता स्कोर (Confidence)',
      'reliable_diagnosis': 'सटीक एवं विश्वसनीय निदान',
      'unverified_diagnosis': 'कम विश्वसनीयता वाला निदान',

      // Chat Screen
      'chat_title': 'कृषि एआई चैटबॉट',
      'chat_hint': 'फसल रोग, उर्वरक, मौसम के बारे में पूछें...',
      'chat_greeting':
          'नमस्ते किसान भाई! मैं जेमिनी संचालित आपका कृषि सहायक हूँ। आज मैं आपकी फसलों की क्या मदद कर सकता हूँ?',
      'chat_thinking': 'कृषि डेटाबेस से जानकारी खोजी जा रही है...',
      'chat_error':
          'जवाब प्राप्त करने में समस्या आई। कृपया इंटरनेट या जेमिनी एपीआई की जाँच करें।',
      'quick_tomato': 'टमाटर में पत्ती मरोड़ एवं धब्बे',
      'quick_fertilizer': 'जैविक खाद की सही मात्रा',
      'quick_fungal': 'आर्द्र मौसम में फफूंद रोग रोकथाम',
      'quick_weather': 'मौसम के अनुसार फसल सुरक्षा उपाय',

      // History Screen
      'history_title': 'निदान इतिहास',
      'history_empty': 'अभी तक कोई स्कैन इतिहास नहीं है।',
      'history_empty_sub': 'पौधे की पत्ती स्कैन करें और यहाँ अपना इतिहास देखें।',
      'delete_scan_confirm': 'क्या आप वाकई इस स्कैन रिकॉर्ड को हटाना चाहते हैं?',

      // Settings Screen
      'settings_title': 'सेटिंग्स',
      'language_setting': 'ऐप की भाषा / Language',
      'gemini_api_key': 'जेमिनी API Key',
      'enter_api_key': 'जेमिनी API Key दर्ज करें',
      'api_key_saved': 'जेमिनी API की सफलतापूर्वक सहेज ली गई!',
      'about_app': 'प्लांटिफाय एआई के बारे में',
      'privacy_policy': 'गोपनीयता नीति',
    },
  };
}
