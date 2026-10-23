import 'package:flutter_test/flutter_test.dart';
import 'package:plant/services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ScanRecord serializes and deserializes correctly', () {
    final now = DateTime.now();
    final record = ScanRecord(
      id: 'test_1',
      dateTime: now,
      imagePath: '/mock/path/leaf.jpg',
      plantName: 'Tomato',
      diseaseName: 'Early Blight',
      confidence: 0.94,
      isReliable: true,
      symptoms: 'Target spots with concentric rings.',
      management: 'Apply copper fungicide.',
      organicControl: 'Neem oil spray.',
      chemicalControl: 'Mancozeb 2.5g/L.',
      sources: ['ICAR-IARI', 'FAO'],
    );

    final json = record.toJson();
    final fromJson = ScanRecord.fromJson(json);

    expect(fromJson.id, equals('test_1'));
    expect(fromJson.plantName, equals('Tomato'));
    expect(fromJson.diseaseName, equals('Early Blight'));
    expect(fromJson.confidence, closeTo(0.94, 0.001));
    expect(fromJson.isReliable, isTrue);
    expect(fromJson.sources.length, equals(2));
  });

  test('HistoryService saves, retrieves, and deletes scans', () async {
    expect(await HistoryService.getScans(), isEmpty);

    final record = ScanRecord(
      id: 'rec_100',
      dateTime: DateTime.now(),
      imagePath: '',
      plantName: 'Potato',
      diseaseName: 'Late Blight',
      confidence: 0.88,
      isReliable: true,
      symptoms: 'Water-soaked lesions on leaves.',
      management: 'Fungicide spray and proper spacing.',
      sources: ['ICAR'],
    );

    await HistoryService.saveScan(record);
    final list = await HistoryService.getScans();
    expect(list.length, equals(1));
    expect(list.first.id, equals('rec_100'));

    await HistoryService.deleteScan('rec_100');
    expect(await HistoryService.getScans(), isEmpty);
  });
}
