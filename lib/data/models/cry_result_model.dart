import 'package:cloud_firestore/cloud_firestore.dart';

enum CryCategory { bellyPain, burping, discomfort, hungry, tired }

class CryResultModel {
  final String id;
  final CryCategory category;
  final double confidence;
  final DateTime timestamp;
  final Map<String, double> allProbabilities;

  const CryResultModel({
    required this.id,
    required this.category,
    required this.confidence,
    required this.timestamp,
    this.allProbabilities = const {},
  });

  String get categoryLabel {
    switch (category) {
      case CryCategory.bellyPain:
        return 'Belly Pain';
      case CryCategory.burping:
        return 'Burping';
      case CryCategory.discomfort:
        return 'Discomfort';
      case CryCategory.hungry:
        return 'Hungry';
      case CryCategory.tired:
        return 'Tired';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case CryCategory.bellyPain:
        return '🤢';
      case CryCategory.burping:
        return '🫧';
      case CryCategory.discomfort:
        return '😣';
      case CryCategory.hungry:
        return '🍼';
      case CryCategory.tired:
        return '😴';
    }
  }

  String get recommendation {
    switch (category) {
      case CryCategory.bellyPain:
        return 'Try gentle tummy massage in clockwise direction. Hold baby upright and apply warm compress to belly. If persistent, consult your pediatrician.';
      case CryCategory.burping:
        return 'Hold baby upright against your shoulder and gently pat their back. Try different burping positions. Feed in smaller, more frequent amounts.';
      case CryCategory.discomfort:
        return 'Check diaper, clothing tightness, and room temperature. Look for tags or seams that may irritate. Ensure comfortable sleeping position.';
      case CryCategory.hungry:
        return 'Baby is likely hungry. Offer breast milk or formula. Look for other hunger cues like lip smacking, rooting, or hand-to-mouth movements.';
      case CryCategory.tired:
        return 'Create a calm, dark environment. Try gentle rocking or swaddling. Use white noise. Follow age-appropriate wake windows for better sleep.';
    }
  }

  factory CryResultModel.fromMap(Map<String, dynamic> map, String id) {
    return CryResultModel(
      id: id,
      category: CryCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => CryCategory.discomfort,
      ),
      confidence: (map['confidence'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      allProbabilities: Map<String, double>.from(map['allProbabilities'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category.name,
      'confidence': confidence,
      'timestamp': Timestamp.fromDate(timestamp),
      'allProbabilities': allProbabilities,
    };
  }
}
