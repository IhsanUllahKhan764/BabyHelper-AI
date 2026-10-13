import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showNotification;
  final bool showSettings;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final List<Widget>? actions;

  const AppBarWidget({
    super.key,
    required this.title,
    this.showBack = false,
    this.showNotification = true,
    this.showSettings = true,
    this.onNotificationTap,
    this.onSettingsTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppDimens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          backgroundColor: AppColors.surfaceBright.withValues(alpha: 0.7),
          leading: showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: AppDimens.iconMd),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          automaticallyImplyLeading: showBack,
          title: Text(title),
          actions: actions ??
              [
                if (showNotification)
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: AppDimens.iconMd),
                    onPressed: onNotificationTap,
                  ),
                if (showSettings)
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: AppDimens.iconMd),
                    onPressed: onSettingsTap,
                  ),
                const SizedBox(width: AppDimens.d4),
              ],
        ),
      ),
    );
  }
}
