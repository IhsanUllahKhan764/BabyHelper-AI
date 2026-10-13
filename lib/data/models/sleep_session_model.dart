import 'package:cloud_firestore/cloud_firestore.dart';

enum SleepQuality { excellent, good, fair, poor }

class SleepSessionModel {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final SleepQuality quality;
  final String? notes;

  const SleepSessionModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.quality,
    this.notes,
  });

  Duration get duration => endTime.difference(startTime);
  double get durationHours => duration.inMinutes / 60.0;

  String get qualityLabel {
    switch (quality) {
      case SleepQuality.excellent:
        return 'Excellent';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.poor:
        return 'Poor';
    }
  }

  String get qualityEmoji {
    switch (quality) {
      case SleepQuality.excellent:
        return '😊';
      case SleepQuality.good:
        return '🙂';
      case SleepQuality.fair:
        return '😐';
      case SleepQuality.poor:
        return '😟';
    }
  }

  factory SleepSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SleepSessionModel(
      id: id,
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      quality: SleepQuality.values.firstWhere(
        (e) => e.name == map['quality'],
        orElse: () => SleepQuality.good,
      ),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'quality': quality.name,
      'notes': notes,
    };
  }
}
