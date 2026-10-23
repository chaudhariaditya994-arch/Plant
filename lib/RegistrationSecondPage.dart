import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plant/Home.dart';
import 'package:plant/LoginPage.dart';
import 'dart:convert';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationSecondPage extends StatefulWidget {
  final Map<String, dynamic> firstPageData;

  const RegistrationSecondPage({super.key, required this.firstPageData});

  @override
  State<RegistrationSecondPage> createState() => _RegistrationSecondPageState();
}

class _RegistrationSecondPageState extends State<RegistrationSecondPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _completeRegistration() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    if (_specialityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your speciality')),
      );
      return;
    }

    if (_birthDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your birth date')),
      );
      return;
    }

    if (_birthPlaceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your birth place')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> registrationData = {
        ...widget.firstPageData,
        'full_name': _fullNameController.text.trim(),
        'first_name': _fullNameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'speciality': _specialityController.text.trim(),
        'birth_date': _birthDateController.text.trim(),
        'birth_place': _birthPlaceController.text.trim(),
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_data', jsonEncode(registrationData));
      await prefs.setString('user_name', _fullNameController.text.trim());

      String token = 'local_user_${DateTime.now().millisecondsSinceEpoch}';

      try {
        final response = await http
            .post(
              Uri.parse('${Config.baseUrl}/api/register/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(registrationData),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['token'] != null) {
            token = responseData['token'];
          }
        }
      } catch (_) {
        // Backend unavailable/timed out — proceed seamlessly with local profile
      }

      await prefs.setString('user_token', token);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row with Back button & Leaf
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFDAE5DD),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(
                        Icons.arrow_back_outlined,
                        size: 26,
                        color: Color(0xFF41734E),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/leaf.png',
                    width: 65,
                    height: 65,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 65, height: 65),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Complete Registration',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64806B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'for better experience',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFA1A1A1),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Full name field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    hintText: 'Full name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF41734E)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.phone_android_outlined, color: Color(0xFF41734E)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Speciality Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _specialityController,
                  decoration: const InputDecoration(
                    hintText: 'Speciality / Role (e.g. Farmer)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.work_outline, color: Color(0xFF41734E)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Birth Date Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      _birthDateController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Birth Date (YYYY-MM-DD)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.date_range_outlined, color: Color(0xFF41734E)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Birth Place Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _birthPlaceController,
                  decoration: const InputDecoration(
                    hintText: 'Location / City',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF41734E)),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Sign Up Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF30625A),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextButton(
                  onPressed: _isLoading ? null : _completeRegistration,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Registration Progress Indicator
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Your registration progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD8E3DB),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'OF',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF41734E),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD8E3DB),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Login redirection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontSize: 14, color: Color(0xFFA1A1A1)),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF41734E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
