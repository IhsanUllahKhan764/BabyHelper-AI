import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baby_helper_ai/data/models/meal_plan_model.dart';

class NutritionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NutritionRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference _mealLogsCol(String babyId) => _firestore
      .collection('users')
      .doc(_uid)
      .collection('babies')
      .doc(babyId)
      .collection('mealLogs');

  CollectionReference _mealPlansCol(String babyId) => _firestore
      .collection('users')
      .doc(_uid)
      .collection('babies')
      .doc(babyId)
      .collection('mealPlans');

  // Meal Logs
  Future<MealLogModel> logMeal(String babyId, MealLogModel meal) async {
    final doc = await _mealLogsCol(babyId).add(meal.toMap());
    return MealLogModel(
      id: doc.id,
      mealType: meal.mealType,
      foodName: meal.foodName,
      timestamp: meal.timestamp,
      notes: meal.notes,
    );
  }

  Future<List<MealLogModel>> getTodayMealLogs(String babyId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot = await _mealLogsCol(babyId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return MealLogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> deleteMealLog(String babyId, String logId) async {
    await _mealLogsCol(babyId).doc(logId).delete();
  }

  // Meal Plans
  Future<MealPlanModel> saveMealPlan(String babyId, MealPlanModel plan) async {
    final doc = await _mealPlansCol(babyId).add(plan.toMap());
    return MealPlanModel(
      id: doc.id,
      title: plan.title,
      weekStart: plan.weekStart,
      dailyPlans: plan.dailyPlans,
      ageInMonths: plan.ageInMonths,
    );
  }

  Future<MealPlanModel?> getLatestMealPlan(String babyId) async {
    final snapshot = await _mealPlansCol(babyId)
        .orderBy('weekStart', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return MealPlanModel.fromMap(
        snapshot.docs.first.data() as Map<String, dynamic>,
        snapshot.docs.first.id);
  }

  // Built-in Recipes (local data)
  List<RecipeModel> getRecipes(int ageInMonths, {List<String> excludeAllergens = const []}) {
    return _builtInRecipes
        .where((r) => r.minAgeMonths <= ageInMonths && r.maxAgeMonths >= ageInMonths)
        .where((r) => !r.allergens.any((a) => excludeAllergens.contains(a)))
        .toList();
  }

  List<RecipeModel> getRecipesByCategory(String category, int ageInMonths,
      {List<String> excludeAllergens = const []}) {
    return getRecipes(ageInMonths, excludeAllergens: excludeAllergens)
        .where((r) => r.category == category)
        .toList();
  }

  // Generate a meal plan based on age
  MealPlanModel generateMealPlan(int ageInMonths, {List<String> excludeAllergens = const []}) {
    final recipes = getRecipes(ageInMonths, excludeAllergens: excludeAllergens);
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    final dailyPlans = days.map((day) {
      final breakfastRecipes = recipes.where((r) => r.category == 'breakfast').toList();
      final lunchRecipes = recipes.where((r) => r.category == 'lunch').toList();
      final dinnerRecipes = recipes.where((r) => r.category == 'dinner').toList();
      final snackRecipes = recipes.where((r) => r.category == 'snack').toList();

      return DailyMealPlan(
        day: day,
        meals: [
          if (breakfastRecipes.isNotEmpty)
            MealItem(
              type: 'breakfast',
              name: breakfastRecipes[days.indexOf(day) % breakfastRecipes.length].title,
              time: '8:00 AM',
            ),
          if (ageInMonths >= 8 && snackRecipes.isNotEmpty)
            MealItem(
              type: 'snack',
              name: snackRecipes[days.indexOf(day) % snackRecipes.length].title,
              time: '10:30 AM',
            ),
          if (lunchRecipes.isNotEmpty)
            MealItem(
              type: 'lunch',
              name: lunchRecipes[days.indexOf(day) % lunchRecipes.length].title,
              time: '12:30 PM',
            ),
          if (ageInMonths >= 9 && snackRecipes.isNotEmpty)
            MealItem(
              type: 'snack',
              name: snackRecipes[(days.indexOf(day) + 1) % snackRecipes.length].title,
              time: '3:30 PM',
            ),
          if (dinnerRecipes.isNotEmpty)
            MealItem(
              type: 'dinner',
              name: dinnerRecipes[days.indexOf(day) % dinnerRecipes.length].title,
              time: '6:00 PM',
            ),
        ],
      );
    }).toList();

    return MealPlanModel(
      id: '',
      title: 'Week Plan for ${ageInMonths}mo',
      weekStart: DateTime.now(),
      dailyPlans: dailyPlans,
      ageInMonths: ageInMonths,
    );
  }

  static final List<RecipeModel> _builtInRecipes = [
    const RecipeModel(
      id: 'r1', title: 'Mashed Banana', description: 'Simple and nutritious first food',
      category: 'breakfast', prepTimeMinutes: 5, minAgeMonths: 6, maxAgeMonths: 12,
      ingredients: ['1 ripe banana'], instructions: ['Peel banana', 'Mash with fork until smooth', 'Serve immediately'],
      nutritionInfo: {'Calories': '89', 'Potassium': 'High', 'Fiber': 'Good'},
    ),
    const RecipeModel(
      id: 'r2', title: 'Sweet Potato Puree', description: 'Rich in vitamins A and C',
      category: 'lunch', prepTimeMinutes: 25, minAgeMonths: 6, maxAgeMonths: 12,
      ingredients: ['1 sweet potato', 'Water or breast milk'], instructions: ['Peel and dice sweet potato', 'Steam for 15 minutes', 'Blend until smooth, add liquid as needed'],
      nutritionInfo: {'Calories': '86', 'Vitamin A': 'Very High', 'Fiber': 'Good'},
    ),
    const RecipeModel(
      id: 'r3', title: 'Avocado Mash', description: 'Healthy fats for brain development',
      category: 'breakfast', prepTimeMinutes: 5, minAgeMonths: 6, maxAgeMonths: 18,
      ingredients: ['1/2 ripe avocado'], instructions: ['Scoop avocado flesh', 'Mash with fork', 'Serve fresh'],
      nutritionInfo: {'Calories': '120', 'Healthy Fats': 'High', 'Potassium': 'Good'},
    ),
    const RecipeModel(
      id: 'r4', title: 'Rice Cereal', description: 'Easy to digest first food',
      category: 'breakfast', prepTimeMinutes: 10, minAgeMonths: 6, maxAgeMonths: 12,
      ingredients: ['2 tbsp rice cereal', 'Breast milk or formula'], instructions: ['Mix cereal with warm milk', 'Stir until smooth consistency', 'Let cool and serve'],
      nutritionInfo: {'Calories': '60', 'Iron': 'Fortified', 'Carbs': 'Good'},
    ),
    const RecipeModel(
      id: 'r5', title: 'Carrot & Apple Puree', description: 'Sweet and nutritious combination',
      category: 'lunch', prepTimeMinutes: 20, minAgeMonths: 6, maxAgeMonths: 12,
      ingredients: ['1 carrot', '1 apple', 'Water'], instructions: ['Peel and dice carrot and apple', 'Steam together for 12-15 minutes', 'Blend until smooth'],
      nutritionInfo: {'Calories': '65', 'Vitamin A': 'High', 'Vitamin C': 'Good'},
    ),
    const RecipeModel(
      id: 'r6', title: 'Oatmeal Porridge', description: 'Fiber-rich and filling',
      category: 'breakfast', prepTimeMinutes: 10, minAgeMonths: 8, maxAgeMonths: 24,
      ingredients: ['3 tbsp oats', '1/2 cup milk', 'Mashed fruit'], instructions: ['Cook oats in milk', 'Stir until thick and creamy', 'Top with mashed fruit'],
      nutritionInfo: {'Calories': '100', 'Fiber': 'High', 'Iron': 'Good'},
      allergens: ['gluten'],
    ),
    const RecipeModel(
      id: 'r7', title: 'Chicken & Vegetable Mash', description: 'Protein-rich meal',
      category: 'dinner', prepTimeMinutes: 30, minAgeMonths: 8, maxAgeMonths: 24,
      ingredients: ['50g chicken breast', '1 carrot', '1 potato', 'Water'], instructions: ['Boil chicken until cooked', 'Steam vegetables until tender', 'Blend everything together to desired texture'],
      nutritionInfo: {'Calories': '130', 'Protein': 'High', 'Iron': 'Good'},
    ),
    const RecipeModel(
      id: 'r8', title: 'Banana Yogurt', description: 'Calcium and vitamin-rich snack',
      category: 'snack', prepTimeMinutes: 5, minAgeMonths: 8, maxAgeMonths: 24,
      ingredients: ['1/2 banana', '3 tbsp plain yogurt'], instructions: ['Mash banana', 'Mix with yogurt', 'Serve chilled'],
      nutritionInfo: {'Calories': '95', 'Calcium': 'High', 'Probiotics': 'Good'},
      allergens: ['dairy'],
    ),
    const RecipeModel(
      id: 'r9', title: 'Lentil Soup', description: 'Great source of iron and protein',
      category: 'dinner', prepTimeMinutes: 35, minAgeMonths: 8, maxAgeMonths: 24,
      ingredients: ['1/4 cup red lentils', '1 carrot', '1 potato', 'Water'], instructions: ['Wash lentils thoroughly', 'Cook with diced vegetables in water', 'Blend until smooth'],
      nutritionInfo: {'Calories': '110', 'Protein': 'High', 'Iron': 'Very High'},
    ),
    const RecipeModel(
      id: 'r10', title: 'Fruit Smoothie', description: 'Refreshing and vitamin-packed',
      category: 'snack', prepTimeMinutes: 5, minAgeMonths: 10, maxAgeMonths: 24,
      ingredients: ['1/2 banana', '3 strawberries', '1/4 cup milk'], instructions: ['Blend all ingredients', 'Serve in a sippy cup', 'Best served fresh'],
      nutritionInfo: {'Calories': '85', 'Vitamin C': 'High', 'Potassium': 'Good'},
      allergens: ['dairy'],
    ),
    const RecipeModel(
      id: 'r11', title: 'Egg & Toast Fingers', description: 'Protein-rich finger food',
      category: 'breakfast', prepTimeMinutes: 10, minAgeMonths: 10, maxAgeMonths: 24,
      ingredients: ['1 egg', '1 slice toast', 'Butter'], instructions: ['Scramble egg gently', 'Cut toast into finger strips', 'Serve together'],
      nutritionInfo: {'Calories': '140', 'Protein': 'High', 'Carbs': 'Good'},
      allergens: ['eggs', 'gluten'],
    ),
    const RecipeModel(
      id: 'r12', title: 'Veggie Pasta Stars', description: 'Fun shapes with healthy sauce',
      category: 'lunch', prepTimeMinutes: 20, minAgeMonths: 10, maxAgeMonths: 24,
      ingredients: ['Small pasta', 'Tomato sauce', 'Zucchini', 'Carrot'], instructions: ['Cook pasta until very soft', 'Steam and dice vegetables', 'Mix with mild tomato sauce', 'Serve warm'],
      nutritionInfo: {'Calories': '150', 'Carbs': 'Good', 'Vitamins': 'Good'},
      allergens: ['gluten'],
    ),
  ];
}
