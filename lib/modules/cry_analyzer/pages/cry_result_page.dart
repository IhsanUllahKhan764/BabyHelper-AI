import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_strings.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_button.dart';
import 'package:baby_helper_ai/core/widgets/app_card.dart';
import 'package:baby_helper_ai/data/models/cry_result_model.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/modules/cry_analyzer/viewmodels/cry_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';
import 'package:baby_helper_ai/core/utils/formatters.dart';

class CryResultPage extends StatelessWidget {
  final CryResultModel result;
  const CryResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.d24),
          child: Column(
            children: [
              // Back row
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerLow),
                  ),
                  const SizedBox(width: AppDimens.d12),
                  Text(AppStrings.cryResult, style: AppTextStyles.titleLarge),
                ],
              ),

              const SizedBox(height: AppDimens.d32),

              // Main result
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.d32),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(result.categoryEmoji, style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: AppDimens.d16),
                    Text(
                      result.categoryLabel,
                      style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppDimens.d8),
                    Text(
                      '${(result.confidence * 100).toStringAsFixed(1)}% confidence',
                      style: AppTextStyles.bodyLarge.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: AppDimens.d4),
                    Text(
                      Formatters.dateTime12h.format(result.timestamp),
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.d24),

              // Recommendation
              AppCard(
                color: AppColors.surfaceContainerLow,
                boxShadow: const [],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimens.d6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          ),
                          child: const Icon(Icons.tips_and_updates_outlined, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppDimens.d8),
                        Text('Recommended Action', style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: AppDimens.d12),
                    Text(
                      result.recommendation,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface, height: 1.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.d20),

              // All probabilities
              if (result.allProbabilities.isNotEmpty) ...[
                AppCard(
                  color: AppColors.surfaceContainerLow,
                  boxShadow: const [],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analysis Breakdown', style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppDimens.d16),
                      ...result.allProbabilities.entries.map((entry) {
                        final percentage = entry.value * 100;
                        final isTop = entry.key.replaceAll('_', '') ==
                            result.category.name.toLowerCase().replaceAll('belly', 'belly');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.d12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key.replaceAll('_', ' ').split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' '),
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: isTop ? AppColors.primary : AppColors.onSurfaceVariant,
                                      fontWeight: isTop ? FontWeight.w700 : FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: isTop ? AppColors.primary : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimens.d4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                                child: LinearProgressIndicator(
                                  value: entry.value,
                                  minHeight: 6,
                                  backgroundColor: AppColors.surfaceContainer,
                                  valueColor: AlwaysStoppedAnimation(isTop ? AppColors.primary : AppColors.outlineVariant),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppDimens.d32),

              AppButton(
                label: 'Save Result',
                style: AppButtonStyle.primary,
                icon: Icons.save_rounded,
                onPressed: () async {
                  final cryVm = context.read<CryViewModel>();
                  final homeVm = context.read<HomeViewModel>();
                  if (homeVm.baby != null) {
                    // cryVm.result might be null if not using the exact same instance, 
                    // but wait, we can just save it. Wait, the Result Page is passed `result` as a param! 
                    // `CryViewModel` still has it as `_result`. 
                    await cryVm.saveResult(homeVm.baby!.id);
                    await cryVm.loadHistory(homeVm.baby!.id);
                    await homeVm.loadDashboard();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Result saved successfully')),
                      );
                      cryVm.reset();
                      context.pop();
                    }
                  }
                },
              ),

              const SizedBox(height: AppDimens.d16),

              AppButton(
                label: 'Retry',
                style: AppButtonStyle.secondary,
                icon: Icons.refresh_rounded,
                onPressed: () {
                  context.read<CryViewModel>().reset();
                  context.pop();
                },
              ),

              const SizedBox(height: AppDimens.d16),
            ],
          ),
        ),
      ),
    );
  }
}
