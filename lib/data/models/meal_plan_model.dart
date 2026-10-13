import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlanModel {
  final String id;
  final String title;
  final DateTime weekStart;
  final List<DailyMealPlan> dailyPlans;
  final int ageInMonths;

  const MealPlanModel({
    required this.id,
    required this.title,
    required this.weekStart,
    required this.dailyPlans,
    required this.ageInMonths,
  });

  factory MealPlanModel.fromMap(Map<String, dynamic> map, String id) {
    return MealPlanModel(
      id: id,
      title: map['title'] ?? 'Meal Plan',
      weekStart: (map['weekStart'] as Timestamp).toDate(),
      dailyPlans: (map['dailyPlans'] as List?)
              ?.map((e) => DailyMealPlan.fromMap(e))
              .toList() ??
          [],
      ageInMonths: map['ageInMonths'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'weekStart': Timestamp.fromDate(weekStart),
      'dailyPlans': dailyPlans.map((e) => e.toMap()).toList(),
      'ageInMonths': ageInMonths,
    };
  }
}

class DailyMealPlan {
  final String day;
  final List<MealItem> meals;

  const DailyMealPlan({required this.day, required this.meals});

  factory DailyMealPlan.fromMap(Map<String, dynamic> map) {
    return DailyMealPlan(
      day: map['day'] ?? '',
      meals: (map['meals'] as List?)?.map((e) => MealItem.fromMap(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'meals': meals.map((e) => e.toMap()).toList(),
    };
  }
}

class MealItem {
  final String type; // breakfast, lunch, dinner, snack
  final String name;
  final String? description;
  final String? time;

  const MealItem({
    required this.type,
    required this.name,
    this.description,
    this.time,
  });

  factory MealItem.fromMap(Map<String, dynamic> map) {
    return MealItem(
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      time: map['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'time': time,
    };
  }
}

class RecipeModel {
  final String id;
  final String title;
  final String description;
  final String category; // breakfast, lunch, dinner, snack
  final int prepTimeMinutes;
  final int minAgeMonths;
  final int maxAgeMonths;
  final List<String> ingredients;
  final List<String> instructions;
  final Map<String, String> nutritionInfo;
  final List<String> allergens;
  final String? imageUrl;

  const RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.prepTimeMinutes,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.ingredients,
    required this.instructions,
    this.nutritionInfo = const {},
    this.allergens = const [],
    this.imageUrl,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    return RecipeModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'snack',
      prepTimeMinutes: map['prepTimeMinutes'] ?? 0,
      minAgeMonths: map['minAgeMonths'] ?? 6,
      maxAgeMonths: map['maxAgeMonths'] ?? 24,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      nutritionInfo: Map<String, String>.from(map['nutritionInfo'] ?? {}),
      allergens: List<String>.from(map['allergens'] ?? []),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'prepTimeMinutes': prepTimeMinutes,
      'minAgeMonths': minAgeMonths,
      'maxAgeMonths': maxAgeMonths,
      'ingredients': ingredients,
      'instructions': instructions,
      'nutritionInfo': nutritionInfo,
      'allergens': allergens,
      'imageUrl': imageUrl,
    };
  }
}

class MealLogModel {
  final String id;
  final String mealType;
  final String foodName;
  final DateTime timestamp;
  final String? notes;

  const MealLogModel({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.timestamp,
    this.notes,
  });

  factory MealLogModel.fromMap(Map<String, dynamic> map, String id) {
    return MealLogModel(
      id: id,
      mealType: map['mealType'] ?? '',
      foodName: map['foodName'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealType': mealType,
      'foodName': foodName,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
    };
  }
}
