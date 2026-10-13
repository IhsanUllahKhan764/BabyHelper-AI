import 'package:flutter/material.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';

enum AppButtonStyle { primary, secondary, outlined, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppDimens.buttonHeightMd,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case AppButtonStyle.primary:
        return _buildPrimary();
      case AppButtonStyle.secondary:
        return _buildSecondary();
      case AppButtonStyle.outlined:
        return _buildOutlined();
      case AppButtonStyle.ghost:
        return _buildGhost();
    }
  }

  Widget _buildPrimary() {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed != null ? AppColors.primaryGradient : null,
        color: onPressed == null ? AppColors.disabled : null,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: AppDimens.d16,
                  offset: const Offset(0, AppDimens.d4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: AppDimens.d24,
                    height: AppDimens.d24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.onPrimary),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.onPrimary, size: AppDimens.iconMd),
                        const SizedBox(width: AppDimens.d8),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondary() {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppDimens.d24,
                height: AppDimens.d24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimens.iconMd),
                    const SizedBox(width: AppDimens.d8),
                  ],
                  Text(label, style: AppTextStyles.button),
                ],
              ),
      ),
    );
  }

  Widget _buildOutlined() {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppDimens.d24,
                height: AppDimens.d24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimens.iconMd),
                    const SizedBox(width: AppDimens.d8),
                  ],
                  Text(label, style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                ],
              ),
      ),
    );
  }

  Widget _buildGhost() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimens.iconMd, color: AppColors.primary),
            const SizedBox(width: AppDimens.d8),
          ],
          Text(
            label,
            style: AppTextStyles.button.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
