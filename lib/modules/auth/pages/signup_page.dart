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

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final authVm = context.read<AuthViewModel>();
    final success = await authVm.signUpWithEmail(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.onboarding);
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
                const SizedBox(height: AppDimens.d32),

                // Back button
                IconButton(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                  ),
                ),

                const SizedBox(height: AppDimens.d24),

                Text(
                  AppStrings.createAccount,
                  style: AppTextStyles.headlineLarge.copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppDimens.d8),
                Text(
                  AppStrings.signupSubtitle,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                ),

                const SizedBox(height: AppDimens.d32),

                AppTextField(
                  label: AppStrings.fullName,
                  hint: 'Your name',
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  validator: Validators.name,
                  prefixIcon: const Icon(Icons.person_outlined, size: AppDimens.iconMd),
                ),
                const SizedBox(height: AppDimens.d20),

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

                AppTextField(
                  label: AppStrings.password,
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outlined, size: AppDimens.iconMd),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: AppDimens.iconMd),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: AppDimens.d20),

                AppTextField(
                  label: AppStrings.confirmPassword,
                  hint: '••••••••',
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text),
                  prefixIcon: const Icon(Icons.lock_outlined, size: AppDimens.iconMd),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: AppDimens.iconMd),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  onFieldSubmitted: (_) => _signup(),
                ),
                const SizedBox(height: AppDimens.d32),

                AppButton(
                  label: AppStrings.createAccount,
                  onPressed: authVm.isLoading ? null : _signup,
                  isLoading: authVm.isLoading,
                ),

                const SizedBox(height: AppDimens.d24),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppStrings.alreadyHaveAccount, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text(AppStrings.login, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
