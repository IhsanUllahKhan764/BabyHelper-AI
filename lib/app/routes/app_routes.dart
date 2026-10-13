/// All route path constants
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String onboarding = '/onboarding';

  // Shell routes (tabs)
  static const String home = '/home';
  static const String cryAnalyzer = '/cry-analyzer';
  static const String growthTracker = '/growth-tracker';
  static const String nutritionGuide = '/nutrition-guide';
  static const String sleepMonitor = '/sleep-monitor';

  // Sub-routes
  static const String cryResult = '/cry-analyzer/result';
  static const String addMeasurement = '/growth-tracker/add';
  static const String recipes = '/nutrition-guide/recipes';
  static const String recipeDetail = '/nutrition-guide/recipes/:id';
  static const String mealPlan = '/nutrition-guide/meal-plan';
  static const String addSleepSession = '/sleep-monitor/add';

  // Settings
  static const String settings = '/settings';
  static const String editBaby = '/settings/edit-baby';
  static const String notifications = '/notifications';
}
