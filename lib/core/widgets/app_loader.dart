import 'package:flutter/material.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';

class AppLoader extends StatelessWidget {
  final bool fullScreen;
  final String? message;

  const AppLoader({super.key, this.fullScreen = false, this.message});

  @override
  Widget build(BuildContext context) {
    final loader = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: AppDimens.d40,
          height: AppDimens.d40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppDimens.d16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: loader),
      );
    }

    return Center(child: Padding(padding: const EdgeInsets.all(AppDimens.d32), child: loader));
  }
}
