import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:baby_helper_ai/data/repositories/auth_repository.dart';
import 'package:baby_helper_ai/data/repositories/baby_repository.dart';
import 'package:baby_helper_ai/data/repositories/cry_repository.dart';
import 'package:baby_helper_ai/data/repositories/growth_repository.dart';
import 'package:baby_helper_ai/data/repositories/nutrition_repository.dart';
import 'package:baby_helper_ai/data/repositories/sleep_repository.dart';
import 'package:baby_helper_ai/data/services/cry_analysis_service.dart';
import 'package:baby_helper_ai/data/services/who_standards_service.dart';
import 'package:baby_helper_ai/modules/auth/viewmodels/auth_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';
import 'package:baby_helper_ai/modules/cry_analyzer/viewmodels/cry_viewmodel.dart';
import 'package:baby_helper_ai/modules/growth/viewmodels/growth_viewmodel.dart';
import 'package:baby_helper_ai/modules/nutrition/viewmodels/nutrition_viewmodel.dart';
import 'package:baby_helper_ai/modules/sleep/viewmodels/sleep_viewmodel.dart';

/// Composition root — all dependency wiring
List<SingleChildWidget> appProviders() => [
      // Services
      Provider<CryAnalysisService>(create: (_) => CryAnalysisService()),
      Provider<WhoStandardsService>(create: (_) => WhoStandardsService()),

      // Repositories
      Provider<AuthRepository>(create: (_) => AuthRepository()),
      Provider<BabyRepository>(create: (_) => BabyRepository()),
      Provider<CryRepository>(create: (_) => CryRepository()),
      Provider<GrowthRepository>(create: (_) => GrowthRepository()),
      Provider<NutritionRepository>(create: (_) => NutritionRepository()),
      Provider<SleepRepository>(create: (_) => SleepRepository()),

      // App-wide ViewModels
      ChangeNotifierProvider<AuthViewModel>(
        create: (ctx) => AuthViewModel(ctx.read<AuthRepository>()),
      ),
      ChangeNotifierProvider<HomeViewModel>(
        create: (ctx) => HomeViewModel(
          ctx.read<BabyRepository>(),
          ctx.read<CryRepository>(),
          ctx.read<GrowthRepository>(),
          ctx.read<SleepRepository>(),
          ctx.read<NutritionRepository>(),
        ),
      ),
      ChangeNotifierProvider<CryViewModel>(
        create: (ctx) => CryViewModel(
          ctx.read<CryAnalysisService>(),
          ctx.read<CryRepository>(),
        ),
      ),
      ChangeNotifierProvider<GrowthViewModel>(
        create: (ctx) => GrowthViewModel(
          ctx.read<GrowthRepository>(),
          ctx.read<WhoStandardsService>(),
        ),
      ),
      ChangeNotifierProvider<NutritionViewModel>(
        create: (ctx) => NutritionViewModel(ctx.read<NutritionRepository>()),
      ),
      ChangeNotifierProvider<SleepViewModel>(
        create: (ctx) => SleepViewModel(ctx.read<SleepRepository>()),
      ),
    ];
