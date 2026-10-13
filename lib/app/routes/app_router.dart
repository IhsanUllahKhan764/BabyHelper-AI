import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/app/routes/app_routes.dart';
import 'package:baby_helper_ai/modules/splash/pages/splash_page.dart';
import 'package:baby_helper_ai/modules/auth/pages/login_page.dart';
import 'package:baby_helper_ai/modules/auth/pages/signup_page.dart';
import 'package:baby_helper_ai/modules/onboarding/pages/baby_setup_page.dart';
import 'package:baby_helper_ai/modules/shell/pages/app_shell.dart';
import 'package:baby_helper_ai/modules/home/pages/home_page.dart';
import 'package:baby_helper_ai/modules/cry_analyzer/pages/cry_recorder_page.dart';
import 'package:baby_helper_ai/modules/cry_analyzer/pages/cry_result_page.dart';
import 'package:baby_helper_ai/modules/growth/pages/growth_page.dart';
import 'package:baby_helper_ai/modules/growth/pages/add_measurement_page.dart';
import 'package:baby_helper_ai/data/models/growth_measurement_model.dart';
import 'package:baby_helper_ai/modules/nutrition/pages/nutrition_page.dart';
import 'package:baby_helper_ai/modules/nutrition/pages/recipes_page.dart';
import 'package:baby_helper_ai/modules/nutrition/pages/meal_plan_page.dart';

import 'package:baby_helper_ai/modules/sleep/pages/sleep_page.dart';
import 'package:baby_helper_ai/modules/sleep/pages/add_sleep_session_page.dart';
import 'package:baby_helper_ai/modules/settings/pages/settings_page.dart';
import 'package:baby_helper_ai/modules/settings/pages/edit_baby_page.dart';
import 'package:baby_helper_ai/modules/notifications/pages/notification_page.dart';
import 'package:baby_helper_ai/modules/auth/viewmodels/auth_viewmodel.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Shared fade-page transition helper
CustomTransitionPage<T> fadePage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => fadePage(child: const SplashPage(), state: state),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => fadePage(child: const LoginPage(), state: state),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => fadePage(child: const SignupPage(), state: state),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => fadePage(child: const BabySetupPage(), state: state),
      ),

      // Main App Shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => fadePage(child: const HomePage(), state: state),
          ),
          GoRoute(
            path: AppRoutes.cryAnalyzer,
            pageBuilder: (context, state) =>
                fadePage(child: const CryRecorderPage(), state: state),
          ),
          GoRoute(
            path: AppRoutes.growthTracker,
            pageBuilder: (context, state) => fadePage(child: const GrowthPage(), state: state),
          ),
          GoRoute(
            path: AppRoutes.nutritionGuide,
            pageBuilder: (context, state) =>
                fadePage(child: const NutritionPage(), state: state),
          ),
          GoRoute(
            path: AppRoutes.sleepMonitor,
            pageBuilder: (context, state) => fadePage(child: const SleepPage(), state: state),
          ),
        ],
      ),

      // Full-screen routes (outside shell)
      GoRoute(
        path: AppRoutes.cryResult,
        pageBuilder: (context, state) => fadePage(
          child: CryResultPage(result: state.extra as dynamic),
          state: state,
        ),
      ),
      GoRoute(
        path: AppRoutes.addMeasurement,
        pageBuilder: (context, state) {
          final existing = state.extra as GrowthMeasurementModel?;
          return fadePage(
            child: AddMeasurementPage(existingMeasurement: existing),
            state: state,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.recipes,
        pageBuilder: (context, state) => fadePage(child: const RecipesPage(), state: state),
      ),
      GoRoute(
        path: AppRoutes.mealPlan,
        pageBuilder: (context, state) => fadePage(child: const MealPlanPage(), state: state),
      ),

      GoRoute(
        path: AppRoutes.addSleepSession,
        pageBuilder: (context, state) =>
            fadePage(child: const AddSleepSessionPage(), state: state),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => fadePage(child: const SettingsPage(), state: state),
      ),
      GoRoute(
        path: AppRoutes.editBaby,
        pageBuilder: (context, state) => fadePage(
          child: EditBabyPage(baby: state.extra as dynamic),
          state: state,
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) =>
            fadePage(child: const NotificationPage(), state: state),
      ),
    ],
    redirect: (context, state) {
      final authVm = context.read<AuthViewModel>();
      final isLoggedIn = authVm.isLoggedIn;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (isSplash) return null;
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.home;
      return null;
    },
  );
}
