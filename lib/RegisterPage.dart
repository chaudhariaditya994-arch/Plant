import 'package:flutter/material.dart';
import 'package:plant/LandingPage.dart';
import 'package:plant/LoginPage.dart';
import 'package:plant/RegistrationSecondPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _validateFirstPage() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return false;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a password')));
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return false;
    }

    return true;
  }

  void _goToSecondPage() {
    if (_validateFirstPage()) {
      final Map<String, dynamic> firstPageData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'password2': _confirmPasswordController.text,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => RegistrationSecondPage(firstPageData: firstPageData),
        ),
      );
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
              // Header Row with Back Button and Decorative Leaf
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
              const SizedBox(height: 12),
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64806B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Create your new account',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFA1A1A1),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

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
              const SizedBox(height: 18),

              // Confirm Password Field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF41734E)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF687B6D),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Next Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF30625A),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextButton(
                  onPressed: _isLoading ? null : _goToSecondPage,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Progress: Step 1 of 2
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
                        '1',
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
              const SizedBox(height: 24),

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
