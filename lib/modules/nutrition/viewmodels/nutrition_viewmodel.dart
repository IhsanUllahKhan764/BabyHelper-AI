import 'package:flutter/material.dart';
import 'package:baby_helper_ai/data/repositories/nutrition_repository.dart';
import 'package:baby_helper_ai/data/models/meal_plan_model.dart';
import 'package:baby_helper_ai/core/errors/api_error_mapper.dart';
import 'package:baby_helper_ai/core/errors/failure.dart';

class NutritionViewModel extends ChangeNotifier {
  final NutritionRepository _nutritionRepo;

  NutritionViewModel(this._nutritionRepo);

  List<RecipeModel> _recipes = [];
  MealPlanModel? _currentPlan;
  List<MealLogModel> _todayLogs = [];
  bool _isLoading = false;
  Failure? _error;

  List<RecipeModel> get recipes => _recipes;
  MealPlanModel? get currentPlan => _currentPlan;
  List<MealLogModel> get todayLogs => _todayLogs;
  bool get isLoading => _isLoading;
  Failure? get error => _error;

  Future<void> loadData(String babyId, int ageInMonths, {List<String> allergens = const []}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _recipes = _nutritionRepo.getRecipes(ageInMonths, excludeAllergens: allergens);
      _currentPlan = await _nutritionRepo.getLatestMealPlan(babyId);
      _todayLogs = await _nutritionRepo.getTodayMealLogs(babyId);
    } catch (e) {
      _error = ApiErrorMapper.map(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadRecipes(int ageInMonths, {List<String> allergens = const []}) {
    _recipes = _nutritionRepo.getRecipes(ageInMonths, excludeAllergens: allergens);
    notifyListeners();
  }

  List<RecipeModel> getRecipesByCategory(String category, int ageInMonths,
      {List<String> allergens = const []}) {
    return _nutritionRepo.getRecipesByCategory(category, ageInMonths,
        excludeAllergens: allergens);
  }

  Future<void> generateMealPlan(String babyId, int ageInMonths,
      {List<String> allergens = const []}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final plan = _nutritionRepo.generateMealPlan(ageInMonths, excludeAllergens: allergens);
      _currentPlan = await _nutritionRepo.saveMealPlan(babyId, plan);
    } catch (e) {
      _error = ApiErrorMapper.map(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logMeal(String babyId, {required String mealType, required String foodName, String? notes}) async {
    try {
      final log = MealLogModel(
        id: '',
        mealType: mealType,
        foodName: foodName,
        timestamp: DateTime.now(),
        notes: notes,
      );
      final saved = await _nutritionRepo.logMeal(babyId, log);
      _todayLogs.insert(0, saved);
      notifyListeners();
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      notifyListeners();
    }
  }

  Future<bool> deleteMealLog(String babyId, String logId) async {
    try {
      await _nutritionRepo.deleteMealLog(babyId, logId);
      _todayLogs.removeWhere((l) => l.id == logId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      notifyListeners();
      return false;
    }
  }
}
