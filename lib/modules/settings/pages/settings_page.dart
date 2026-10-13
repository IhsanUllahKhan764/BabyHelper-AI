import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/app/routes/app_routes.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_button.dart';
import 'package:baby_helper_ai/core/widgets/app_card.dart';
import 'package:baby_helper_ai/core/widgets/app_avatar.dart';
import 'package:baby_helper_ai/core/widgets/app_toast.dart';
import 'package:baby_helper_ai/core/utils/formatters.dart';
import 'package:baby_helper_ai/data/models/baby_model.dart';
import 'package:baby_helper_ai/modules/auth/viewmodels/auth_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final homeVm = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.d24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerLow),
                  ),
                  const SizedBox(width: AppDimens.d12),
                  Text('Settings', style: AppTextStyles.titleLarge),
                ],
              ),
              const SizedBox(height: AppDimens.d32),

              // User profile
              AppCard(
                color: AppColors.surfaceContainerLow,
                boxShadow: const [],
                child: Row(
                  children: [
                    AppAvatar(
                      name: authVm.userName,
                      imageUrl: authVm.firebaseUser?.photoURL,
                      size: 56,
                    ),
                    const SizedBox(width: AppDimens.d16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(authVm.userName, style: AppTextStyles.titleMedium),
                          Text(authVm.firebaseUser?.email ?? '', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.d28),

              // Baby Profiles Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Baby Profiles', style: AppTextStyles.titleMedium),
                  IconButton(
                    onPressed: () async {
                      await context.push(AppRoutes.onboarding);
                      if (context.mounted) homeVm.loadDashboard();
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(AppDimens.d6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      child: const Icon(Icons.add, size: 20, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.d12),

              if (homeVm.allBabies.isEmpty)
                AppCard(
                  color: AppColors.surfaceContainerLow,
                  boxShadow: const [],
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.child_care, size: 40, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: AppDimens.d8),
                        Text('No baby profiles yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: AppDimens.d12),
                        AppButton(
                          label: 'Add Baby',
                          width: 140,
                          onPressed: () async {
                            await context.push(AppRoutes.onboarding);
                            if (context.mounted) homeVm.loadDashboard();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...homeVm.allBabies.map((baby) {
                  final isActive = homeVm.baby?.id == baby.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.d8),
                    child: GestureDetector(
                      onTap: () => homeVm.switchBaby(baby.id),
                      child: AppCard(
                        color: isActive
                            ? AppColors.primaryContainer.withValues(alpha: 0.15)
                            : AppColors.surfaceContainerLow,
                        boxShadow: const [],
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primary : AppColors.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  baby.gender == BabyGender.male ? '👦' : '👧',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.d12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(baby.name, style: AppTextStyles.labelLarge.copyWith(
                                        color: isActive ? AppColors.primary : AppColors.onSurface,
                                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                      )),
                                      if (isActive) ...[
                                        const SizedBox(width: AppDimens.d8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                                          ),
                                          child: Text('Active', style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 9)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    '${Formatters.formatAge(baby.dateOfBirth)} • ${baby.gender == BabyGender.male ? 'Boy' : 'Girl'}',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            // Edit button
                            IconButton(
                              onPressed: () async {
                                await context.push(AppRoutes.editBaby, extra: baby);
                                if (context.mounted) homeVm.loadDashboard();
                              },
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.onSurfaceVariant),
                            ),
                            // Delete button
                            IconButton(
                              onPressed: () => _confirmDeleteBaby(context, baby, homeVm),
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: AppDimens.d28),

              // App settings
              Text('App', style: AppTextStyles.titleSmall.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: AppDimens.d12),
              AppCard(
                color: AppColors.surfaceContainerLow,
                boxShadow: const [],
                child: Column(
                  children: [
                    _SettingRow(icon: Icons.info_outline, title: 'Version', value: '1.0.0'),
                    _SettingRow(icon: Icons.description_outlined, title: 'Terms of Service', onTap: () {}),
                    _SettingRow(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () {}),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.d32),

              // Sign out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authVm.signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.d14),
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.d32),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteBaby(BuildContext context, BabyModel baby, HomeViewModel homeVm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Baby Profile'),
        content: Text('Are you sure you want to delete ${baby.name}\'s profile? All data will be permanently lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await homeVm.deleteBaby(baby.id);
              if (context.mounted) {
                AppToast.show(context, message: '${baby.name}\'s profile deleted', type: ToastType.success);
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  const _SettingRow({required this.icon, required this.title, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.d10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
            const SizedBox(width: AppDimens.d12),
            Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
            if (value != null)
              Text(value!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
            if (onTap != null)
              const Icon(Icons.chevron_right, size: 20, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
