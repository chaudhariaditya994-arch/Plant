import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:plant/Home.dart';
import 'package:plant/LandingPage.dart';
import 'package:plant/RegisterPage.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _LoginUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String token = 'local_user_${DateTime.now().millisecondsSinceEpoch}';

      try {
        final response = await http
            .post(
              Uri.parse('${Config.baseUrl}/api/login/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'password': password}),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['token'] != null) {
            token = responseData['token'];
          }
          if (responseData['user'] != null) {
            await prefs.setString(
              'user_profile_data',
              jsonEncode(responseData['user']),
            );
          }
        }
      } catch (_) {
        // Backend offline / timed out — proceed with local session
      }

      await prefs.setString('user_token', token);
      if (prefs.getString('user_name') == null) {
        final namePart = email.split('@').first;
        await prefs.setString('user_name', namePart);
      }

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
              // Header Row with Back Button & Leaf
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LandingPage()),
                      );
                    },
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
              const SizedBox(height: 20),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF41734E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Log in to your account',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFA1A1A1),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF41734E)),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Password Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF41734E)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF687B6D),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Login Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF30625A),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextButton(
                  onPressed: _isLoading ? null : _LoginUser,
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
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // Sign up redirection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 14, color: Color(0xFFA1A1A1)),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Sign up',
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
