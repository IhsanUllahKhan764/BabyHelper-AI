import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/app/routes/app_routes.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_strings.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_bar_widget.dart';
import 'package:baby_helper_ai/core/widgets/app_card.dart';
import 'package:baby_helper_ai/core/widgets/app_loader.dart';
import 'package:baby_helper_ai/core/widgets/app_toast.dart';
import 'package:baby_helper_ai/core/utils/formatters.dart';
import 'package:baby_helper_ai/modules/nutrition/viewmodels/nutrition_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = context.read<HomeViewModel>().baby;
      if (baby != null) {
        context.read<NutritionViewModel>().loadData(baby.id, baby.ageInMonths, allergens: baby.allergens);
      }
    });
  }

  void _showLogMealSheet() {
    final baby = context.read<HomeViewModel>().baby;
    if (baby == null) {
      AppToast.show(context, message: 'Set up baby profile first', type: ToastType.warning);
      return;
    }

    String selectedType = 'breakfast';
    final foodCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      backgroundColor: AppColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppDimens.d24,
            right: AppDimens.d24,
            top: AppDimens.d24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimens.d24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.d20),
              Text('Log Feeding', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppDimens.d20),

              // Meal type chips
              Text('Meal Type', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: AppDimens.d8),
              Wrap(
                spacing: 8,
                children: ['breakfast', 'lunch', 'dinner', 'snack'].map((type) {
                  final isSelected = selectedType == type;
                  return ChoiceChip(
                    label: Text(type[0].toUpperCase() + type.substring(1)),
                    selected: isSelected,
                    onSelected: (_) => setModalState(() => selectedType = type),
                    selectedColor: AppColors.nutritionAccent.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.nutritionAccent : AppColors.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.nutritionAccent : AppColors.outlineVariant,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimens.d16),

              // Food name
              TextField(
                controller: foodCtrl,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'e.g. Mashed banana',
                  prefixIcon: const Icon(Icons.restaurant_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.d12),

              // Notes
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Amount, reaction, etc.',
                  prefixIcon: const Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.d24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (foodCtrl.text.trim().isEmpty) {
                      AppToast.show(ctx, message: 'Enter a food name', type: ToastType.warning);
                      return;
                    }
                    await context.read<NutritionViewModel>().logMeal(
                      baby.id,
                      mealType: selectedType,
                      foodName: foodCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      AppToast.show(context, message: 'Meal logged!', type: ToastType.success);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Log Meal'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.nutritionAccent,
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.d14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteMealLog(String logId) async {
    final baby = context.read<HomeViewModel>().baby;
    if (baby == null) return;
    final success = await context.read<NutritionViewModel>().deleteMealLog(baby.id, logId);
    if (mounted) {
      AppToast.show(context,
        message: success ? 'Meal log deleted' : 'Failed to delete',
        type: success ? ToastType.success : ToastType.error,
      );
    }
  }

  bool _dailyReminder = false;

  @override
  Widget build(BuildContext context) {
    final nutritionVm = context.watch<NutritionViewModel>();

    return Scaffold(
      appBar: AppBarWidget(
        title: AppStrings.nutritionGuide,
        actions: [
          Row(
            children: [
              Text(
                'Reminders',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
              Switch(
                value: _dailyReminder,
                onChanged: (val) {
                  setState(() => _dailyReminder = val);
                },
                activeThumbColor: AppColors.nutritionAccent,
              ),
            ],
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: nutritionVm.isLoading
          ? const AppLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.d24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.add_circle_outline,
                          label: 'Log Meal',
                          color: AppColors.nutritionAccent,
                          onTap: _showLogMealSheet,
                        ),
                      ),
                      const SizedBox(width: AppDimens.d12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.calendar_view_week,
                          label: 'Meal Plan',
                          color: const Color(0xFF00B894),
                          onTap: () => context.push(AppRoutes.mealPlan),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.d28),

                  // Meal Plan Preview (Today)
                  if (nutritionVm.currentPlan != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Today\'s Plan', style: AppTextStyles.titleMedium),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.mealPlan),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.d8),
                    AppCard(
                      color: AppColors.surfaceContainerLow,
                      boxShadow: const [],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(builder: (context) {
                            final todayName = [
                              'Monday',
                              'Tuesday',
                              'Wednesday',
                              'Thursday',
                              'Friday',
                              'Saturday',
                              'Sunday'
                            ][DateTime.now().weekday - 1];
                            
                            final todayPlan = nutritionVm.currentPlan!.dailyPlans.firstWhere(
                              (d) => d.day == todayName,
                              orElse: () => nutritionVm.currentPlan!.dailyPlans.first,
                            );

                            if (todayPlan.meals.isEmpty) {
                              return Text(
                                'No solid foods recommended yet for this age.',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                              );
                            }

                            return Column(
                              children: todayPlan.meals.map((meal) => Padding(
                                padding: const EdgeInsets.only(bottom: AppDimens.d8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.nutritionAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimens.d8),
                                    Text(
                                      '${meal.time ?? ""} ',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                                    ),
                                    Expanded(
                                      child: Text(meal.name, style: AppTextStyles.bodyMedium),
                                    ),
                                    Text(
                                      meal.type,
                                      style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.d28),
                  ],

                  // Today's meals
                  Text("Today's Meals", style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppDimens.d12),

                  if (nutritionVm.todayLogs.isEmpty)
                    AppCard(
                      color: AppColors.surfaceContainerLow,
                      boxShadow: const [],
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.restaurant_outlined, size: 40, color: AppColors.onSurfaceVariant),
                            const SizedBox(height: AppDimens.d8),
                            Text('No meals logged today', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppDimens.d4),
                            Text('Tap + to log your baby\'s feeding', style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...nutritionVm.todayLogs.map((log) => Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.d8),
                      child: Dismissible(
                        key: Key(log.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppDimens.d20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          ),
                          child: const Icon(Icons.delete_outline, color: AppColors.error),
                        ),
                        confirmDismiss: (_) async {
                          await _deleteMealLog(log.id);
                          return false;
                        },
                        child: AppCard(
                          color: AppColors.surfaceContainerLow,
                          boxShadow: const [],
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppDimens.d8),
                                decoration: BoxDecoration(
                                  color: AppColors.nutritionAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                ),
                                child: Icon(_mealIcon(log.mealType), size: 20, color: AppColors.nutritionAccent),
                              ),
                              const SizedBox(width: AppDimens.d12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(log.foodName, style: AppTextStyles.labelLarge),
                                    Text('${log.mealType} • ${Formatters.time12h.format(log.timestamp)}', style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant)),
                                    if (log.notes != null && log.notes!.isNotEmpty)
                                      Text(log.notes!, style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),

                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }

  IconData _mealIcon(String type) {
    switch (type) {
      case 'breakfast': return Icons.wb_sunny_outlined;
      case 'lunch': return Icons.restaurant_outlined;
      case 'dinner': return Icons.nightlight_outlined;
      case 'snack': return Icons.cookie_outlined;
      default: return Icons.restaurant_outlined;
    }
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.d16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppDimens.d8),
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
