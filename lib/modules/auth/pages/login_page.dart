import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/app/routes/app_routes.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_strings.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_button.dart';
import 'package:baby_helper_ai/core/widgets/app_text_field.dart';
import 'package:baby_helper_ai/core/widgets/app_toast.dart';
import 'package:baby_helper_ai/core/utils/validators.dart';
import 'package:baby_helper_ai/modules/auth/viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authVm = context.read<AuthViewModel>();
    final success = await authVm.signInWithEmail(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.home);
    } else if (authVm.error != null) {
      AppToast.show(context, message: authVm.error!.message, type: ToastType.error);
    }
  }

  Future<void> _googleSignIn() async {
    final authVm = context.read<AuthViewModel>();
    final success = await authVm.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.home);
    } else if (authVm.error != null) {
      AppToast.show(context, message: authVm.error!.message, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimens.d48),

                // Header icon
                Container(
                  width: AppDimens.d64,
                  height: AppDimens.d64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: const Icon(
                    Icons.child_care_rounded,
                    size: AppDimens.iconLg,
                    color: AppColors.onPrimary,
                  ),
                ),

                const SizedBox(height: AppDimens.d24),

                // Title
                Text(
                  AppStrings.welcomeBack,
                  style: AppTextStyles.headlineLarge.copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppDimens.d8),
                Text(
                  AppStrings.loginSubtitle,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                ),

                const SizedBox(height: AppDimens.d40),

                // Email
                AppTextField(
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined, size: AppDimens.iconMd),
                ),

                const SizedBox(height: AppDimens.d20),

                // Password
                AppTextField(
                  label: AppStrings.password,
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outlined, size: AppDimens.iconMd),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: AppDimens.iconMd,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onFieldSubmitted: (_) => _login(),
                ),

                const SizedBox(height: AppDimens.d32),

                // Login button
                AppButton(
                  label: AppStrings.login,
                  onPressed: authVm.isLoading ? null : _login,
                  isLoading: authVm.isLoading,
                ),

                const SizedBox(height: AppDimens.d24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.d16),
                      child: Text(
                        AppStrings.orContinueWith,
                        style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3))),
                  ],
                ),

                const SizedBox(height: AppDimens.d24),

                // Google Sign In
                AppButton(
                  label: AppStrings.googleSignIn,
                  style: AppButtonStyle.outlined,
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: authVm.isLoading ? null : _googleSignIn,
                ),

                const SizedBox(height: AppDimens.d32),

                // Sign up link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.signup),
                        child: Text(
                          AppStrings.signup,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.d32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
