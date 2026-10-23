import 'package:flutter/material.dart';
import 'package:plant/Home.dart';
import 'package:plant/RegisterPage.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/WelcomeImage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.1, // 30% from the top
                left: screenWidth * 0.1, // 10% from the left
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the left
                children: [
                  _buildText("The best", 45.0),
                  _buildText("app for", 45.0),
                  _buildText("your plant", 45.0),
                ],
              ),
            ),
            const Spacer(), // Push the button to the bottom
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.08),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF30625A).withOpacity(0.7),
                            const Color(0xFF244A44).withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenHeight * 0.15,
                            vertical: 10,
                          ),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
                        );
                      },
                      child: const Text(
                        'Continue as Guest  →',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
