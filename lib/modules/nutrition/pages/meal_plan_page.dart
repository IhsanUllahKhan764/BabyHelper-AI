import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_button.dart';
import 'package:baby_helper_ai/core/widgets/app_card.dart';
import 'package:baby_helper_ai/core/widgets/app_loader.dart';
import 'package:baby_helper_ai/core/widgets/app_toast.dart';
import 'package:baby_helper_ai/modules/nutrition/viewmodels/nutrition_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';

class MealPlanPage extends StatelessWidget {
  const MealPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nutritionVm = context.watch<NutritionViewModel>();
    final baby = context.watch<HomeViewModel>().baby;
    final plan = nutritionVm.currentPlan;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                  Text('Meal Plan', style: AppTextStyles.titleLarge),
                  const Spacer(),
                  if (baby != null)
                    TextButton.icon(
                      onPressed: nutritionVm.isLoading
                          ? null
                          : () async {
                              await nutritionVm.generateMealPlan(
                                baby.id,
                                baby.ageInMonths,
                                allergens: baby.allergens,
                              );
                              if (context.mounted) {
                                AppToast.show(
                                  context,
                                  message: 'Meal plan generated!',
                                  type: ToastType.success,
                                );
                              }
                            },
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Generate'),
                    ),
                ],
              ),
            ),
            if (nutritionVm.isLoading)
              const Expanded(
                child: AppLoader(message: 'Generating meal plan...'),
              )
            else if (plan == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_view_week,
                        size: 64,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppDimens.d16),
                      Text(
                        'No meal plan yet',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: AppDimens.d8),
                      Text(
                        'Generate a weekly plan based on age',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimens.d24),
                      if (baby != null)
                        AppButton(
                          label: 'Generate Meal Plan',
                          width: 220,
                          onPressed: () async {
                            await nutritionVm.generateMealPlan(
                              baby.id,
                              baby.ageInMonths,
                              allergens: baby.allergens,
                            );
                            if (context.mounted) {
                              AppToast.show(
                                context,
                                message: 'Meal plan generated!',
                                type: ToastType.success,
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.d24,
                  ),
                  itemCount: plan.dailyPlans.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppDimens.d12),
                  itemBuilder: (context, index) {
                    final day = plan.dailyPlans[index];
                    return AppCard(
                      color: AppColors.surfaceContainerLow,
                      boxShadow: const [],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.day,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppDimens.d8),
                          if (day.meals.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: AppDimens.d4),
                              child: Text(
                                'No solid foods recommended yet for this age.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            )
                          else
                            ...day.meals.map(
                              (meal) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimens.d6,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimens.d8),
                                    Text(
                                      '${meal.time ?? ""} ',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        meal.name,
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ),
                                    Text(
                                      meal.type,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
