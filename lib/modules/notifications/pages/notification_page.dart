import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_empty_state.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerLow),
                  ),
                  const SizedBox(width: AppDimens.d12),
                  Text('Notifications', style: AppTextStyles.titleLarge),
                ],
              ),
            ),
            const Expanded(
              child: AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications yet',
                subtitle: 'We\'ll notify you about important milestones and reminders',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
