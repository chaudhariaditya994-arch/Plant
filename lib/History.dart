import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plant/PlantDetail.dart';
import 'package:plant/services/history_service.dart';
import 'package:plant/services/localization_service.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<ScanRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final items = await HistoryService.getScans();
    if (mounted) {
      setState(() {
        _records = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRecord(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(LocalizationService.tr('delete')),
        content: Text(LocalizationService.tr('delete_scan_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(LocalizationService.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(LocalizationService.tr('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.deleteScan(id);
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2E4032), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationService.tr('history_title'),
          style: const TextStyle(
            color: Color(0xFF2E4032),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF517159)),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF517159)))
          : _records.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFF517159),
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final scan = _records[index];
                      return _buildScanCard(scan);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF517159).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 40,
                color: Color(0xFF517159),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LocalizationService.tr('history_empty'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E4032),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              LocalizationService.tr('history_empty_sub'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard(ScanRecord scan) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final formattedDate = dateFormat.format(scan.dateTime);
    final hasImage = scan.imagePath.isNotEmpty && File(scan.imagePath).existsSync();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantDetail(
                diseaseId: 1,
                isDefaultDisease: true,
                predictedClass: '${scan.plantName} - ${scan.diseaseName}',
                diseaseDetails: {
                  'id': 1,
                  'is_default': true,
                  'plant_name': scan.plantName,
                  'disease_name': scan.diseaseName,
                  'confidence': scan.confidence,
                  'is_reliable': scan.isReliable,
                  'symptoms': scan.symptoms,
                  'management': scan.management,
                  'organic_control': scan.organicControl,
                  'chemical_control': scan.chemicalControl,
                  'sources': scan.sources,
                },
                capturedImage: hasImage ? File(scan.imagePath) : null,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 65,
                  height: 65,
                  child: hasImage
                      ? Image.file(File(scan.imagePath), fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFEFF5F0),
                          child: const Icon(Icons.eco, color: Color(0xFF517159), size: 30),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.plantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2E4032),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scan.diseaseName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF517159),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: scan.isReliable
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: scan.isReliable
                                  ? Colors.green.shade300
                                  : Colors.orange.shade300,
                            ),
                          ),
                          child: Text(
                            '${(scan.confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: scan.isReliable
                                  ? Colors.green.shade800
                                  : Colors.orange.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete action
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey.shade400),
                onPressed: () => _deleteRecord(scan.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
