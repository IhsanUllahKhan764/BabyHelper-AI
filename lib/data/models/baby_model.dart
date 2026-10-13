import 'package:cloud_firestore/cloud_firestore.dart';

enum BabyGender { male, female }

class BabyModel {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final BabyGender gender;
  final String? photoUrl;
  final String? bloodType;
  final List<String> allergens;
  final String? medicalNotes;
  final double? birthWeight;
  final double? birthHeight;
  final double? birthHeadCircumference;
  final bool isPremature;
  final int? gestationalAge;
  final DateTime createdAt;
  final DateTime updatedAt;

  BabyModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.photoUrl,
    this.bloodType,
    this.allergens = const [],
    this.medicalNotes,
    this.birthWeight,
    this.birthHeight,
    this.birthHeadCircumference,
    this.isPremature = false,
    this.gestationalAge,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
  }

  int get ageInDays => DateTime.now().difference(dateOfBirth).inDays;

  factory BabyModel.fromMap(Map<String, dynamic> map, String id) {
    return BabyModel(
      id: id,
      name: map['name'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      gender: map['gender'] == 'male' ? BabyGender.male : BabyGender.female,
      photoUrl: map['photoUrl'],
      bloodType: map['bloodType'],
      allergens: List<String>.from(map['allergens'] ?? []),
      medicalNotes: map['medicalNotes'],
      birthWeight: (map['birthWeight'] as num?)?.toDouble(),
      birthHeight: (map['birthHeight'] as num?)?.toDouble(),
      birthHeadCircumference: (map['birthHeadCircumference'] as num?)?.toDouble(),
      isPremature: map['isPremature'] ?? false,
      gestationalAge: map['gestationalAge'],
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender == BabyGender.male ? 'male' : 'female',
      'photoUrl': photoUrl,
      'bloodType': bloodType,
      'allergens': allergens,
      'medicalNotes': medicalNotes,
      'birthWeight': birthWeight,
      'birthHeight': birthHeight,
      'birthHeadCircumference': birthHeadCircumference,
      'isPremature': isPremature,
      'gestationalAge': gestationalAge,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  BabyModel copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    BabyGender? gender,
    String? photoUrl,
    String? bloodType,
    List<String>? allergens,
    String? medicalNotes,
    double? birthWeight,
    double? birthHeight,
    double? birthHeadCircumference,
    bool? isPremature,
    int? gestationalAge,
  }) {
    return BabyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      bloodType: bloodType ?? this.bloodType,
      allergens: allergens ?? this.allergens,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      birthWeight: birthWeight ?? this.birthWeight,
      birthHeight: birthHeight ?? this.birthHeight,
      birthHeadCircumference: birthHeadCircumference ?? this.birthHeadCircumference,
      isPremature: isPremature ?? this.isPremature,
      gestationalAge: gestationalAge ?? this.gestationalAge,
      createdAt: createdAt,
    );
  }
}
