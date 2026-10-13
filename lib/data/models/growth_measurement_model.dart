import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthMeasurementModel {
  final String id;
  final double height; // cm
  final double weight; // kg
  final double headCircumference; // cm
  final DateTime date;
  final double? heightZScore;
  final double? weightZScore;
  final double? headZScore;
  final double? bmiZScore;

  const GrowthMeasurementModel({
    required this.id,
    required this.height,
    required this.weight,
    required this.headCircumference,
    required this.date,
    this.heightZScore,
    this.weightZScore,
    this.headZScore,
    this.bmiZScore,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  factory GrowthMeasurementModel.fromMap(Map<String, dynamic> map, String id) {
    return GrowthMeasurementModel(
      id: id,
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      headCircumference: (map['headCircumference'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      heightZScore: map['heightZScore']?.toDouble(),
      weightZScore: map['weightZScore']?.toDouble(),
      headZScore: map['headZScore']?.toDouble(),
      bmiZScore: map['bmiZScore']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'weight': weight,
      'headCircumference': headCircumference,
      'date': Timestamp.fromDate(date),
      'heightZScore': heightZScore,
      'weightZScore': weightZScore,
      'headZScore': headZScore,
      'bmiZScore': bmiZScore,
    };
  }

  GrowthMeasurementModel copyWith({
    double? heightZScore,
    double? weightZScore,
    double? headZScore,
    double? bmiZScore,
  }) {
    return GrowthMeasurementModel(
      id: id,
      height: height,
      weight: weight,
      headCircumference: headCircumference,
      date: date,
      heightZScore: heightZScore ?? this.heightZScore,
      weightZScore: weightZScore ?? this.weightZScore,
      headZScore: headZScore ?? this.headZScore,
      bmiZScore: bmiZScore ?? this.bmiZScore,
    );
  }
}
