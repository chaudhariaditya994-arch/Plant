import 'package:flutter/material.dart';

class DiseaseDetail extends StatelessWidget {
  final Map<String, dynamic> disease;

  const DiseaseDetail({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final String fullName = disease['name'] ?? 'Unknown Disease';
    final List<String> nameParts = fullName.split(' ');
    final String firstWord = nameParts.isNotEmpty ? nameParts.first : 'Unknown';
    final String remainingWords =
        nameParts.length > 1 ? ' ${nameParts.sublist(1).join(' ')}' : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            children: [
              TextSpan(
                text: firstWord,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: remainingWords,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF41734E),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Disease Illustration
              Center(
                child: Image.asset(
                  'assets/plant/DiseaseDetailImage.png',
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.eco,
                    size: 100,
                    color: Color(0xFF41734E),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Content Card (Symptoms and Management)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3E5F3E),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Symptoms Header
                    const Text(
                      'Symptoms',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        disease['symptoms'] ?? 'No symptoms available.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Management Header
                    const Text(
                      'Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        disease['management'] ?? 'No management information available.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
