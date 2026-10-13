import 'package:flutter_test/flutter_test.dart';
import 'package:baby_helper_ai/data/services/who_standards_service.dart';
import 'package:baby_helper_ai/data/models/growth_measurement_model.dart';
import 'package:baby_helper_ai/data/models/baby_model.dart';

void main() {
  test('WHO Z-Score Calculation Test', () {
    final service = WhoStandardsService();
    
    // Test case 1: 6-month male, 7.5kg, 67cm, 43cm
    final baby = BabyModel(
      id: '1',
      name: 'Test Baby',
      dateOfBirth: DateTime(2025, 11, 1),
      gender: BabyGender.male,
    );
    
    final measurement = GrowthMeasurementModel(
      id: 'm1',
      weight: 7.5,
      height: 67.0,
      headCircumference: 43.0,
      date: DateTime(2026, 5, 1), // Exactly 6 months later
    );
    
    final result = service.calculateZScores(measurement, baby);
    print('TC1 Weight Z: ${result.weightZScore?.toStringAsFixed(2)}');
    print('TC1 Height Z: ${result.heightZScore?.toStringAsFixed(2)}');
    print('TC1 Head Z: ${result.headZScore?.toStringAsFixed(2)}');
    
    // Test case 2: 6-month male, 5.0kg
    final measurement2 = GrowthMeasurementModel(
      id: 'm2',
      weight: 5.0,
      height: 67.0,
      headCircumference: 43.0,
      date: DateTime(2026, 5, 1),
    );
    final result2 = service.calculateZScores(measurement2, baby);
    print('TC2 Weight Z: ${result2.weightZScore?.toStringAsFixed(2)}');
    
    // Test case 3: 6-month male, 11.0kg
    final measurement3 = GrowthMeasurementModel(
      id: 'm3',
      weight: 11.0,
      height: 67.0,
      headCircumference: 43.0,
      date: DateTime(2026, 5, 1),
    );
    final result3 = service.calculateZScores(measurement3, baby);
    print('TC3 Weight Z: ${result3.weightZScore?.toStringAsFixed(2)}');
    
    // Test case: 0-month male, 7.5kg (THE USER'S ACCIDENTAL TEST)
    final measurement0 = GrowthMeasurementModel(
      id: 'm0',
      weight: 7.5,
      height: 67.0,
      headCircumference: 43.0,
      date: DateTime(2025, 11, 1), // Same as DOB
    );
    final result0 = service.calculateZScores(measurement0, baby);
    print('TC0 (Birth) Weight Z: ${result0.weightZScore?.toStringAsFixed(2)}');
  });
}
