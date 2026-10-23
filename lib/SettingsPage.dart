import 'package:flutter/material.dart';
import 'package:plant/History.dart';
import 'package:plant/PrivacyPolicyPage.dart';
import 'package:plant/config.dart';
import 'package:plant/services/localization_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await Config.getGeminiApiKey();
    _apiKeyController.text = key;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            LocalizationService.tr('language_setting'),
            style: const TextStyle(
              color: Color(0xFF2E4032),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLangTile('English', 'English', 'en'),
              _buildLangTile('मराठी', 'Marathi', 'mr'),
              _buildLangTile('हिंदी', 'Hindi', 'hi'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                LocalizationService.tr('close'),
                style: const TextStyle(color: Color(0xFF517159)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLangTile(String title, String subtitle, String code) {
    final isSelected = LocalizationService.currentLanguage == code;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF517159) : Colors.black87,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF517159))
          : null,
      onTap: () async {
        await LocalizationService.setLanguage(code);
        if (mounted) {
          Navigator.pop(context);
          setState(() {});
        }
      },
    );
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            LocalizationService.tr('gemini_api_key'),
            style: const TextStyle(
              color: Color(0xFF2E4032),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get your free Gemini API key from Google AI Studio (aistudio.google.com).',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'AIzaSy...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF517159), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                LocalizationService.tr('cancel'),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF517159),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await Config.setGeminiApiKey(_apiKeyController.text);
                if (mounted) {
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(LocalizationService.tr('api_key_saved')),
                      backgroundColor: const Color(0xFF517159),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final bannerHeight = 160.0 + topPadding;

    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Top Gradient Banner
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: screenWidth,
                    height: bannerHeight,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B6546), Color(0xFF3F704C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: topPadding + 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: topPadding + 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        LocalizationService.tr('settings_title'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: bannerHeight - 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: const Color(0xFFEFF5F0),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          size: 50,
                          color: Color(0xFF517159),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Settings List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                  children: [
                    _buildSectionHeader('AI & Language'),
                    _buildSettingItem(
                      context,
                      icon: Icons.language,
                      title: LocalizationService.tr('language_setting'),
                      subtitle: LocalizationService.currentLanguage == 'mr'
                          ? 'मराठी'
                          : (LocalizationService.currentLanguage == 'hi'
                              ? 'हिंदी'
                              : 'English'),
                      onTap: _showLanguageDialog,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.key,
                      title: LocalizationService.tr('gemini_api_key'),
                      subtitle: 'Google Gemini 1.5 Flash Vision & Chat',
                      onTap: _showApiKeyDialog,
                    ),

                    const SizedBox(height: 16),
                    _buildSectionHeader('Records & History'),
                    _buildSettingItem(
                      context,
                      icon: Icons.history_outlined,
                      title: LocalizationService.tr('history_title'),
                      subtitle: 'View saved plant leaf scans and advice',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const History()),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    _buildSectionHeader('App & Legal'),
                    _buildSettingItem(
                      context,
                      icon: Icons.info_outline,
                      title: LocalizationService.tr('about_app'),
                      subtitle: 'Plantify AI Smart Agriculture Assistant v1.0',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Plantify AI'),
                            content: const Text(
                              'Plantify is an AI-powered smart agriculture assistant providing plant disease detection, evidence-based agricultural recommendations from ICAR and FAO, real-time weather alerts, and Gemini-powered conversational advisory in English, Marathi, and Hindi.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(LocalizationService.tr('close')),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: LocalizationService.tr('privacy_policy'),
                      subtitle: 'Data usage & offline privacy',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF5F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF517159), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
