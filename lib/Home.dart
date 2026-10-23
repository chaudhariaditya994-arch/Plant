import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant/Chatpage.dart';
import 'package:plant/History.dart';
import 'package:plant/PlantDetail.dart';
import 'package:plant/ProfilePage.dart';
import 'package:plant/SettingsPage.dart';
import 'package:plant/api_service.dart';
import 'package:plant/custom_dialog.dart';
import 'package:plant/services/localization_service.dart';
import 'package:plant/services/weather_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _dividerAnimation;
  late Animation<double> _card1Animation;
  late Animation<double> _card2Animation;
  late Animation<double> _card3Animation;
  late Animation<double> _navBarAnimation;

  WeatherAdvisoryData? _weatherData;
  bool _isLoadingWeather = true;

  final List<Map<String, String>> _icons = [
    {
      'inactive': 'assets/icons/home.png',
      'active': 'assets/icons/homeActive.png',
    },
    {'inactive': 'assets/icons/chat.png', 'active': 'assets/icons/chat.png'},
    {
      'inactive': 'assets/icons/camera.png',
      'active': 'assets/icons/camera.png',
    },
    {
      'inactive': 'assets/icons/community.png',
      'active': 'assets/icons/communityActive.png',
    },
    {
      'inactive': 'assets/icons/profile.png',
      'active': 'assets/icons/profile.png',
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutQuint),
      ),
    );

    _dividerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.4, curve: Curves.easeInOut),
      ),
    );

    _card1Animation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOutQuint),
      ),
    );

    _card2Animation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.7, curve: Curves.easeOutQuint),
      ),
    );

    _card3Animation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOutQuint),
      ),
    );

    _navBarAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutQuint),
      ),
    );

    _animationController.forward();
    _loadWeather();
  }

  Future<void> _loadWeather([WeatherLocation? location]) async {
    setState(() => _isLoadingWeather = true);
    final data = await WeatherService.fetchWeather(location);
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoadingWeather = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processImage(File imageFile) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF517159)),
                const SizedBox(height: 16),
                Text(
                  LocalizationService.tr('processing_image'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );

      final prediction = await ApiService.predictDisease(imageFile);
      if (mounted) Navigator.pop(context); // Close loading dialog

      // Validate if it is a genuine plant image
      if (prediction.containsKey('is_plant') && prediction['is_plant'] == false) {
        if (!mounted) return;
        await showCustomDialog(
          context: context,
          message: LocalizationService.tr('not_plant_error'),
          isError: true,
        );
        return;
      }

      // Check confidence reliability
      if (prediction.containsKey('is_reliable') &&
          prediction['is_reliable'] == false) {
        if (!mounted) return;
        await showCustomDialog(
          context: context,
          message: LocalizationService.tr('low_confidence_error'),
          isError: true,
        );
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantDetail(
            diseaseId: prediction['plant_disease'] ?? 1,
            isDefaultDisease:
                prediction['disease_details']?['is_default'] ?? true,
            predictedClass: prediction['predicted_class'] ?? 'Plant Disease',
            diseaseDetails:
                prediction['disease_details'] ?? <String, dynamic>{},
            capturedImage: imageFile,
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      showCustomDialog(
        context: context,
        message: LocalizationService.tr('not_plant_error'),
        isError: true,
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    await _processImage(File(pickedFile.path));
                  }
                },
                icon: const Icon(Icons.camera_alt, color: Color(0xFF517159)),
                label: Text(
                  LocalizationService.tr('camera'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    await _processImage(File(pickedFile.path));
                  }
                },
                icon: const Icon(Icons.photo_library, color: Color(0xFF517159)),
                label: Text(
                  LocalizationService.tr('gallery'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationService.tr('change_city'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF517159),
                ),
              ),
              const SizedBox(height: 12),
              ...WeatherService.predefinedLocations.map((loc) {
                final isSelected = loc.name == WeatherService.selectedLocation.name;
                return ListTile(
                  dense: true,
                  title: Text(
                    '${loc.name}, ${loc.state}',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF517159) : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF517159))
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _loadWeather(loc);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        break;
      case 1: // Chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(weatherContext: _weatherData),
          ),
        );
        break;
      case 2: // Camera
        _showImageSourceActionSheet(context);
        break;
      case 3: // History
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const History()),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double topPadding = MediaQuery.of(context).padding.top;

    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F5F7),
          body: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Top Header
                  Positioned(
                    top: topPadding + 10 + _headerAnimation.value,
                    left: 24,
                    right: 24,
                    child: Opacity(
                      opacity: (1 - _headerAnimation.value.abs() / 50).clamp(0.0, 1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/leaf.png',
                                width: 28,
                                height: 28,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.eco,
                                  color: Color(0xFF517159),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                LocalizationService.tr('greeting_title'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E4032),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
                                ),
                              );
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.settings_outlined, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: topPadding + 58,
                    left: 24,
                    right: 24,
                    child: Opacity(
                      opacity: _dividerAnimation.value,
                      child: Divider(
                        color: Colors.grey.withValues(alpha: 0.3),
                        thickness: 1,
                      ),
                    ),
                  ),

                  // Scrollable Section
                  Positioned(
                    top: topPadding + 68,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weather Advisory Widget
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildWeatherCard(),
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              LocalizationService.tr('what_we_offer'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E4032),
                              ),
                            ),
                          ),

                          // Card 1: Disease Diagnosis (Clickable)
                          Transform.translate(
                            offset: Offset(0, _card1Animation.value),
                            child: Opacity(
                              opacity: (1 - _card1Animation.value / 80).clamp(0.0, 1.0),
                              child: _buildCustomContainer(
                                screenWidth,
                                firstText: LocalizationService.tr('card1_first'),
                                secondText: LocalizationService.tr('card1_second'),
                                firstTextColor: Colors.black87,
                                secondTextColor: const Color(0xFF517159),
                                imagePath: 'assets/Home/cameraHome.png',
                                paragraphText: LocalizationService.tr('card1_desc'),
                                onTap: () => _showImageSourceActionSheet(context),
                              ),
                            ),
                          ),

                          // Card 2: Weather & Advisory (Clickable)
                          Transform.translate(
                            offset: Offset(0, _card2Animation.value),
                            child: Opacity(
                              opacity: (1 - _card2Animation.value / 80).clamp(0.0, 1.0),
                              child: _buildCustomContainer(
                                screenWidth,
                                firstText: LocalizationService.tr('card2_first'),
                                secondText: LocalizationService.tr('card2_second'),
                                firstTextColor: Colors.black87,
                                secondTextColor: const Color(0xFF517159),
                                imagePath: 'assets/Home/recommondation.png',
                                paragraphText: LocalizationService.tr('card2_desc'),
                                onTap: () => _showLocationPicker(context),
                              ),
                            ),
                          ),

                          // Card 3: AI Chatbot (Clickable)
                          Transform.translate(
                            offset: Offset(0, _card3Animation.value),
                            child: Opacity(
                              opacity: (1 - _card3Animation.value / 80).clamp(0.0, 1.0),
                              child: _buildCustomContainer(
                                screenWidth,
                                firstText: LocalizationService.tr('card3_first'),
                                secondText: LocalizationService.tr('card3_second'),
                                firstTextColor: Colors.black87,
                                secondTextColor: const Color(0xFF517159),
                                imagePath: 'assets/Home/chatbot.png',
                                paragraphText: LocalizationService.tr('card3_desc'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        weatherContext: _weatherData,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _navBarAnimation.value),
                child: Opacity(
                  opacity: (1 - _navBarAnimation.value / 50).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: BottomNavigationBar(
                      currentIndex: _selectedIndex,
                      onTap: _onItemTapped,
                      items: _icons.map((icon) {
                        return BottomNavigationBarItem(
                          icon: Image.asset(
                            icon['inactive']!,
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) => const Icon(Icons.circle),
                          ),
                          activeIcon: Image.asset(
                            icon['active']!,
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) => const Icon(Icons.circle),
                          ),
                          label: '',
                        );
                      }).toList(),
                      selectedItemColor: const Color(0xFF41734E),
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWeatherCard() {
    if (_isLoadingWeather || _weatherData == null) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF517159)),
        ),
      );
    }

    final weather = _weatherData!;
    Color riskColor = Colors.green;
    String riskLabel = LocalizationService.tr('risk_low');
    if (weather.riskLevel == 'high') {
      riskColor = Colors.red.shade700;
      riskLabel = LocalizationService.tr('risk_high');
    } else if (weather.riskLevel == 'moderate') {
      riskColor = Colors.orange.shade800;
      riskLabel = LocalizationService.tr('risk_moderate');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF517159), size: 18),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        weather.cityName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showLocationPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF5F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        LocalizationService.tr('change_city'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF517159),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          size: 16, color: Color(0xFF517159)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherMetric(
                Icons.thermostat,
                '${weather.temperature.toStringAsFixed(1)}°C',
                LocalizationService.tr('temp_label'),
              ),
              _buildWeatherMetric(
                Icons.water_drop,
                '${weather.humidity}%',
                LocalizationService.tr('humidity_label'),
              ),
              _buildWeatherMetric(
                Icons.cloudy_snowing,
                '${weather.precipitation} mm',
                LocalizationService.tr('rain_label'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: riskColor),
                    const SizedBox(width: 6),
                    Text(
                      riskLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  weather.advisoryText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF517159), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCustomContainer(
    double screenWidth, {
    required String firstText,
    required String secondText,
    required Color firstTextColor,
    required Color secondTextColor,
    required String imagePath,
    required String paragraphText,
    required VoidCallback onTap,
    double imageWidth = 115,
    double imageHeight = 115,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            height: 180,
            width: screenWidth - 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: firstText,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: firstTextColor,
                              ),
                            ),
                            TextSpan(
                              text: ' $secondText',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: secondTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: screenWidth * 0.48,
                        child: Text(
                          paragraphText,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 4,
                  child: Image.asset(
                    imagePath,
                    width: imageWidth,
                    height: imageHeight,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Color(0xFF517159),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
