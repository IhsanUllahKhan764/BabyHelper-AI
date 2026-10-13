import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/app/routes/app_routes.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_strings.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_card.dart';
import 'package:baby_helper_ai/core/widgets/app_loader.dart';
import 'package:baby_helper_ai/core/utils/formatters.dart';
import 'package:baby_helper_ai/modules/auth/viewmodels/auth_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final homeVm = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: homeVm.isLoading && homeVm.baby == null
            ? const AppLoader()
            : RefreshIndicator(
                onRefresh: () => homeVm.loadDashboard(),
                color: AppColors.primary,
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.d24,
                          AppDimens.d16,
                          AppDimens.d24,
                          0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppStrings.welcome},',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    authVm.userName,
                                    style: AppTextStyles.headlineMedium
                                        .copyWith(color: AppColors.onSurface),
                                  ),
                                  if (homeVm.baby != null)
                                    Text(
                                      '${homeVm.baby!.name} • ${Formatters.formatAge(homeVm.baby!.dateOfBirth)}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.notifications),
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.settings),
                                  icon: const Icon(Icons.settings_outlined),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppDimens.d24),
                    ),

                    // Module cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.d24,
                        ),
                        child: Text(
                          AppStrings.modules,
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppDimens.d12),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.d24,
                          ),
                          children: [
                            _ModuleCard(
                              title: 'Cry\nAnalyzer',
                              icon: Icons.mic_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
                              ),
                              onTap: () => context.go(AppRoutes.cryAnalyzer),
                            ),
                            const SizedBox(width: AppDimens.d12),
                            _ModuleCard(
                              title: 'Growth\nTracker',
                              icon: Icons.show_chart_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF55EFC4), Color(0xFF00B894)],
                              ),
                              onTap: () => context.go(AppRoutes.growthTracker),
                            ),
                            const SizedBox(width: AppDimens.d12),
                            _ModuleCard(
                              title: 'Nutrition\nGuide',
                              icon: Icons.restaurant_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                              ),
                              onTap: () => context.go(AppRoutes.nutritionGuide),
                            ),
                            const SizedBox(width: AppDimens.d12),
                            _ModuleCard(
                              title: 'Sleep\nMonitor',
                              icon: Icons.bedtime_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFA29BFE), Color(0xFF6C5CE7)],
                              ),
                              onTap: () => context.go(AppRoutes.sleepMonitor),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppDimens.d28),
                    ),

                    // AI Tip
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.d24,
                        ),
                        child: AppCard(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.15,
                          ),
                          boxShadow: const [],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppDimens.d6),
                                    decoration: BoxDecoration(
                                      color: AppColors.aiInsightAccent
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(
                                        AppDimens.radiusSm,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      size: 18,
                                      color: AppColors.aiInsightAccent,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.d8),
                                  Text(
                                    AppStrings.todayTip,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimens.d12),
                              Text(
                                homeVm.aiTip,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onSurface,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppDimens.d28),
                    ),

                    // Recent Activity
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.d24,
                        ),
                        child: Text(
                          AppStrings.recentActivity,
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppDimens.d12),
                    ),

                    if (homeVm.recentActivity.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.d24,
                          ),
                          child: AppCard(
                            boxShadow: const [],
                            color: AppColors.surfaceContainerLow,
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.history,
                                    size: 40,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: AppDimens.d8),
                                  Text(
                                    'No recent activity yet',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimens.d4),
                                  Text(
                                    'Start using the modules above!',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.d24,
                        ),
                        sliver: SliverList.separated(
                          itemCount: homeVm.recentActivity.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppDimens.d8),
                          itemBuilder: (context, index) {
                            final activity = homeVm.recentActivity[index];
                            return Dismissible(
                              key: Key('${activity['module']}_${activity['id']}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: AppDimens.d24),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                                ),
                                child: const Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                homeVm.deleteActivity(activity['id'], activity['module']);
                              },
                              child: AppCard(
                                boxShadow: const [],
                                color: AppColors.surfaceContainerLow,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppDimens.d8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppDimens.radiusSm,
                                        ),
                                      ),
                                      child: Icon(
                                        activity['icon'] as IconData,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimens.d12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity['module'] as String,
                                            style: AppTextStyles.labelLarge,
                                          ),
                                          Text(
                                            activity['summary'] as String,
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      Formatters.relativeTime(
                                        activity['time'] as DateTime,
                                      ),
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Bottom padding for nav bar
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(AppDimens.d16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.d8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
