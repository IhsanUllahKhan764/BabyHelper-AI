import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_card.dart';
import 'package:baby_helper_ai/core/widgets/app_empty_state.dart';
import 'package:baby_helper_ai/modules/nutrition/viewmodels/nutrition_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nutritionVm = context.read<NutritionViewModel>();
      if (nutritionVm.recipes.isEmpty) {
        final baby = context.read<HomeViewModel>().baby;
        if (baby != null) {
          nutritionVm.loadRecipes(baby.ageInMonths, allergens: baby.allergens);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nutritionVm = context.watch<NutritionViewModel>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.d24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerLow,
                      ),
                    ),
                    const SizedBox(width: AppDimens.d12),
                    Text('Recipes', style: AppTextStyles.titleLarge),
                  ],
                ),
              ),
            ),
            if (nutritionVm.recipes.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.restaurant_menu,
                  title: 'No recipes available',
                  subtitle: 'Recipes will appear based on your baby\'s age profile',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24),
                sliver: SliverList.separated(
                itemCount: nutritionVm.recipes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppDimens.d12),
                itemBuilder: (context, index) {
                  final recipe = nutritionVm.recipes[index];
                  return AppCard(
                    color: AppColors.surfaceContainerLow,
                    boxShadow: const [],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusSm,
                                ),
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppDimens.d12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.title,
                                    style: AppTextStyles.titleSmall,
                                  ),
                                  Text(
                                    '${recipe.prepTimeMinutes} min • ${recipe.category}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.d12),
                        Text(
                          recipe.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppDimens.d12),
                        Text(
                          'Ingredients',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppDimens.d4),
                        ...recipe.ingredients.map(
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppDimens.d8),
                                Text(i, style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                        ),
                        if (recipe.allergens.isNotEmpty) ...[
                          const SizedBox(height: AppDimens.d8),
                          Wrap(
                            spacing: 6,
                            children: recipe.allergens
                                .map(
                                  (a) => Chip(
                                    label: Text(
                                      a,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                    backgroundColor: AppColors.warning
                                        .withValues(alpha: 0.1),
                                    side: BorderSide.none,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.d32)),
          ],
        ),
      ),
    );
  }
}
