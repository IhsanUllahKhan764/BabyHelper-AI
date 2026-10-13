import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_helper_ai/app/routes/app_routes.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.cryAnalyzer)) return 1;
    if (location.startsWith(AppRoutes.growthTracker)) return 2;
    if (location.startsWith(AppRoutes.nutritionGuide)) return 3;
    if (location.startsWith(AppRoutes.sleepMonitor)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.cryAnalyzer);
      case 2:
        context.go(AppRoutes.growthTracker);
      case 3:
        context.go(AppRoutes.nutritionGuide);
      case 4:
        context.go(AppRoutes.sleepMonitor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceBright.withValues(alpha: 0.85),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ambientShadow,
                  blurRadius: 32,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: AppDimens.bottomNavHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isActive: current == 0,
                      onTap: () => _onTap(context, 0),
                    ),
                    _NavItem(
                      icon: Icons.mic_rounded,
                      label: 'Cry',
                      isActive: current == 1,
                      onTap: () => _onTap(context, 1),
                      accentColor: AppColors.healthAccent,
                    ),
                    _NavItem(
                      icon: Icons.show_chart_rounded,
                      label: 'Growth',
                      isActive: current == 2,
                      onTap: () => _onTap(context, 2),
                      accentColor: AppColors.growthAccent,
                    ),
                    _NavItem(
                      icon: Icons.restaurant_rounded,
                      label: 'Nutrition',
                      isActive: current == 3,
                      onTap: () => _onTap(context, 3),
                      accentColor: AppColors.nutritionAccent,
                    ),
                    _NavItem(
                      icon: Icons.bedtime_rounded,
                      label: 'Sleep',
                      isActive: current == 4,
                      onTap: () => _onTap(context, 4),
                      accentColor: AppColors.sleepAccent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? accentColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? (accentColor ?? AppColors.primary) : AppColors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.d12, vertical: AppDimens.d4),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: Icon(icon, size: AppDimens.iconMd, color: color),
            ),
            const SizedBox(height: AppDimens.d2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
