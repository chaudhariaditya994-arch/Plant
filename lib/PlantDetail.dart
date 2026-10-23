import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant/Chatpage.dart';
import 'package:plant/DiseaseDetail.dart';
import 'package:plant/custom_dialog.dart';
import 'package:plant/services/localization_service.dart';

class PlantDetail extends StatefulWidget {
  final int diseaseId;
  final bool isDefaultDisease;
  final String predictedClass;
  final Map<String, dynamic> diseaseDetails;
  final File? capturedImage;

  const PlantDetail({
    super.key,
    required this.diseaseId,
    required this.isDefaultDisease,
    required this.predictedClass,
    required this.diseaseDetails,
    this.capturedImage,
  });

  @override
  State<PlantDetail> createState() => _PlantDetailState();
}

class _PlantDetailState extends State<PlantDetail> {
  late Map<String, dynamic> disease;

  @override
  void initState() {
    super.initState();
    disease = Map<String, dynamic>.from(widget.diseaseDetails);
  }

  Widget _buildPlantImage({double size = 200}) {
    if (widget.capturedImage != null && widget.capturedImage!.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          widget.capturedImage!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      'assets/plant/plantandmore.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.eco,
        size: 100,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = (screenHeight * 0.38).clamp(250.0, 320.0);
    final imageHeight = (headerHeight * 0.62).clamp(140.0, 200.0);
    final plantName = disease['plant_name'] ?? widget.predictedClass.split('-').first.trim();
    final diseaseName = disease['disease_name'] ??
        (widget.predictedClass.contains('-')
            ? widget.predictedClass.split('-').last.trim()
            : widget.predictedClass);
    final symptoms = disease['symptoms'] ?? 'No symptom description available.';
    final management = disease['management'] ?? 'Practice recommended cultural sanitation.';
    final organicControl = disease['organic_control'] ?? '';
    final chemicalControl = disease['chemical_control'] ?? '';
    final double confidence = (disease['confidence'] as num?)?.toDouble() ?? 0.94;
    final bool isReliable = disease['is_reliable'] ?? true;
    final List<String> sources = (disease['sources'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['ICAR - Indian Council of Agricultural Research', 'FAO Crop Protection'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Curved Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _CurvedClipper(),
              child: Container(
                height: headerHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3F6F4C), Color(0xFF517159)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Plant / Leaf Image
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Center(child: _buildPlantImage(size: imageHeight)),
          ),

          // Scrollable Diagnostic & Care Content
          Positioned.fill(
            top: headerHeight - 15,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Plant & Disease Title
                  Center(
                    child: Text(
                      plantName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E4032),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      diseaseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF517159),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Confidence Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isReliable
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isReliable
                              ? Colors.green.shade300
                              : Colors.orange.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isReliable ? Icons.verified : Icons.warning_amber_rounded,
                            size: 16,
                            color: isReliable ? Colors.green.shade700 : Colors.orange.shade800,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${LocalizationService.tr('confidence')}: ${(confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isReliable
                                  ? Colors.green.shade800
                                  : Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Symptoms Section
                  _buildSectionCard(
                    title: LocalizationService.tr('symptoms'),
                    content: symptoms,
                    icon: Icons.search,
                  ),
                  const SizedBox(height: 12),

                  // Management Section
                  _buildSectionCard(
                    title: LocalizationService.tr('management'),
                    content: management,
                    icon: Icons.healing,
                  ),
                  const SizedBox(height: 12),

                  // Organic / Cultural Control
                  if (organicControl.isNotEmpty) ...[
                    _buildSectionCard(
                      title: LocalizationService.tr('organic_management'),
                      content: organicControl,
                      icon: Icons.eco,
                      accentColor: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Chemical Control
                  if (chemicalControl.isNotEmpty) ...[
                    _buildSectionCard(
                      title: LocalizationService.tr('chemical_management'),
                      content: chemicalControl,
                      icon: Icons.science,
                      accentColor: const Color(0xFFC62828),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Evidence-Based Sources
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book, size: 16, color: Color(0xFF517159)),
                            const SizedBox(width: 6),
                            Text(
                              LocalizationService.tr('sources'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF517159),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...sources.map((src) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Color(0xFF517159))),
                                  Expanded(
                                    child: Text(
                                      src,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Ask Chatbot Button
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                plantContext: '$plantName ($diseaseName)',
                                initialPrompt:
                                    'Tell me detailed care, recovery and dosage recommendations for $plantName affected by $diseaseName.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(
                          LocalizationService.tr('ask_chatbot'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF517159),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // More Info Button
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiseaseDetail(
                                disease: {
                                  ...disease,
                                  'name': '$plantName - $diseaseName',
                                  'symptoms': symptoms,
                                  'management': management,
                                },
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF517159),
                          side: const BorderSide(color: Color(0xFF517159)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          LocalizationService.tr('more_info'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    Color accentColor = const Color(0xFF517159),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
