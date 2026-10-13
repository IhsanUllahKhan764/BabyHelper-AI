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
import 'package:baby_helper_ai/data/repositories/baby_repository.dart';
import 'package:baby_helper_ai/data/models/baby_model.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';
import 'package:intl/intl.dart';

class BabySetupPage extends StatefulWidget {
  const BabySetupPage({super.key});

  @override
  State<BabySetupPage> createState() => _BabySetupPageState();
}

class _BabySetupPageState extends State<BabySetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bloodTypeCtrl = TextEditingController();
  final _birthWeightCtrl = TextEditingController();
  final _birthHeightCtrl = TextEditingController();
  final _birthHeadCtrl = TextEditingController();
  DateTime? _selectedDob;
  BabyGender _selectedGender = BabyGender.male;
  bool _isPremature = false;
  final _gestationalAgeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bloodTypeCtrl.dispose();
    _birthWeightCtrl.dispose();
    _birthHeightCtrl.dispose();
    _birthHeadCtrl.dispose();
    _gestationalAgeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      AppToast.show(context, message: 'Please select date of birth', type: ToastType.warning);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final babyRepo = context.read<BabyRepository>();
      final baby = await babyRepo.createBaby(BabyModel(
        id: '',
        name: _nameCtrl.text.trim(),
        dateOfBirth: _selectedDob!,
        gender: _selectedGender,
        bloodType: _bloodTypeCtrl.text.trim().isNotEmpty ? _bloodTypeCtrl.text.trim() : null,
        birthWeight: double.tryParse(_birthWeightCtrl.text),
        birthHeight: double.tryParse(_birthHeightCtrl.text),
        birthHeadCircumference: double.tryParse(_birthHeadCtrl.text),
        isPremature: _isPremature,
        gestationalAge: int.tryParse(_gestationalAgeCtrl.text),
      ));
      if (!mounted) return;
      // Update home viewmodel with new baby
      context.read<HomeViewModel>().setBaby(baby);
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, message: 'Failed to save baby profile', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

                // Back button (only if from settings)
                if (GoRouter.of(context).canPop())
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerLow),
                  ),

                const SizedBox(height: AppDimens.d16),

                // Hero illustration
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.child_friendly_rounded, size: 40, color: AppColors.onPrimary),
                  ),
                ),

                const SizedBox(height: AppDimens.d16),

                Center(child: Text(AppStrings.setupBabyProfile, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface))),
                const SizedBox(height: AppDimens.d4),
                Center(child: Text('Tell us about your little one', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant))),

                const SizedBox(height: AppDimens.d28),

                // Baby name
                AppTextField(
                  label: AppStrings.babyName,
                  hint: "Enter baby's name",
                  controller: _nameCtrl,
                  validator: Validators.name,
                  prefixIcon: const Icon(Icons.child_care_rounded, size: AppDimens.iconMd),
                ),
                const SizedBox(height: AppDimens.d20),

                // Date of birth
                Text(AppStrings.babyDob, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppDimens.d8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.d16, vertical: AppDimens.d14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: AppColors.onSurfaceVariant, size: AppDimens.iconMd),
                        const SizedBox(width: AppDimens.d12),
                        Text(
                          _selectedDob != null ? DateFormat('MMMM d, yyyy').format(_selectedDob!) : 'Select date of birth',
                          style: AppTextStyles.bodyLarge.copyWith(color: _selectedDob != null ? AppColors.onSurface : AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.d20),

                // Gender
                Text(AppStrings.babyGender, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppDimens.d8),
                Row(
                  children: [
                    _GenderChip(label: AppStrings.male, emoji: '👦', isSelected: _selectedGender == BabyGender.male, onTap: () => setState(() => _selectedGender = BabyGender.male)),
                    const SizedBox(width: AppDimens.d16),
                    _GenderChip(label: AppStrings.female, emoji: '👧', isSelected: _selectedGender == BabyGender.female, onTap: () => setState(() => _selectedGender = BabyGender.female)),
                  ],
                ),
                const SizedBox(height: AppDimens.d20),

                // Blood Type
                AppTextField(
                  label: 'Blood Type (optional)',
                  hint: 'e.g. A+, B-, O+',
                  controller: _bloodTypeCtrl,
                  prefixIcon: const Icon(Icons.bloodtype_outlined, size: AppDimens.iconMd),
                ),
                const SizedBox(height: AppDimens.d20),

                // Birth measurements
                Text('Birth Measurements (optional)', style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary)),
                const SizedBox(height: AppDimens.d12),
                Row(
                  children: [
                    Expanded(child: AppTextField(label: 'Weight (kg)', hint: '3.2', controller: _birthWeightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: AppDimens.d12),
                    Expanded(child: AppTextField(label: 'Height (cm)', hint: '50', controller: _birthHeightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                const SizedBox(height: AppDimens.d12),
                AppTextField(label: 'Head Circ. (cm)', hint: '34', controller: _birthHeadCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: AppDimens.d20),

                // Premature toggle
                Row(
                  children: [
                    Expanded(child: Text('Premature Birth', style: AppTextStyles.bodyMedium)),
                    Switch(value: _isPremature, onChanged: (v) => setState(() => _isPremature = v), activeTrackColor: AppColors.primary.withValues(alpha: 0.5)),
                  ],
                ),
                if (_isPremature)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimens.d12),
                    child: AppTextField(label: 'Gestational Age (weeks)', hint: '36', controller: _gestationalAgeCtrl, keyboardType: TextInputType.number),
                  ),

                const SizedBox(height: AppDimens.d32),

                AppButton(label: AppStrings.continueText, onPressed: _isLoading ? null : _save, isLoading: _isLoading),

                const SizedBox(height: AppDimens.d12),

                if (!GoRouter.of(context).canPop())
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: Text(AppStrings.skip, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
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

class _GenderChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChip({required this.label, required this.emoji, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppDimens.d12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.2) : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: AppDimens.d4),
              Text(label, style: AppTextStyles.labelLarge.copyWith(color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
