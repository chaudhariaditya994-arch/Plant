import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScanRecord {
  final String id;
  final DateTime dateTime;
  final String imagePath;
  final String plantName;
  final String diseaseName;
  final double confidence;
  final bool isReliable;
  final String symptoms;
  final String management;
  final String organicControl;
  final String chemicalControl;
  final List<String> sources;

  ScanRecord({
    required this.id,
    required this.dateTime,
    required this.imagePath,
    required this.plantName,
    required this.diseaseName,
    required this.confidence,
    required this.isReliable,
    required this.symptoms,
    required this.management,
    this.organicControl = '',
    this.chemicalControl = '',
    required this.sources,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'imagePath': imagePath,
        'plantName': plantName,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'isReliable': isReliable,
        'symptoms': symptoms,
        'management': management,
        'organicControl': organicControl,
        'chemicalControl': chemicalControl,
        'sources': sources,
      };

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
      imagePath: json['imagePath'] ?? '',
      plantName: json['plantName'] ?? 'Unknown Plant',
      diseaseName: json['diseaseName'] ?? 'Unspecified Disease',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      isReliable: json['isReliable'] ?? true,
      symptoms: json['symptoms'] ?? 'No symptom details available.',
      management: json['management'] ?? 'No management steps available.',
      organicControl: json['organicControl'] ?? '',
      chemicalControl: json['chemicalControl'] ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['ICAR - Indian Council of Agricultural Research', 'FAO Crop Protection'],
    );
  }
}

class HistoryService {
  static const String _storageKey = 'plant_scan_history';

  static Future<List<ScanRecord>> getScans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = json.decode(jsonString);
      final List<ScanRecord> scans =
          decoded.map((item) => ScanRecord.fromJson(item)).toList();
      scans.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return scans;
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveScan(ScanRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<ScanRecord> current = await getScans();
      current.insert(0, record);
      // Keep up to 100 historical scans
      if (current.length > 100) {
        current.removeLast();
      }
      final encoded = json.encode(current.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      // Ignore save failure
    }
  }

  static Future<void> deleteScan(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<ScanRecord> current = await getScans();
      current.removeWhere((item) => item.id == id);
      final encoded = json.encode(current.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      // Ignore delete failure
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
