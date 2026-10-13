import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_button.dart';
import 'package:baby_helper_ai/core/widgets/app_text_field.dart';
import 'package:baby_helper_ai/core/widgets/app_toast.dart';
import 'package:baby_helper_ai/core/utils/validators.dart';
import 'package:baby_helper_ai/data/models/baby_model.dart';
import 'package:baby_helper_ai/data/repositories/baby_repository.dart';
import 'package:intl/intl.dart';

class EditBabyPage extends StatefulWidget {
  final BabyModel baby;
  const EditBabyPage({super.key, required this.baby});

  @override
  State<EditBabyPage> createState() => _EditBabyPageState();
}

class _EditBabyPageState extends State<EditBabyPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _bloodTypeCtrl;
  late TextEditingController _medicalNotesCtrl;
  late TextEditingController _birthWeightCtrl;
  late TextEditingController _birthHeightCtrl;
  late TextEditingController _birthHeadCtrl;
  late TextEditingController _gestationalAgeCtrl;
  late DateTime _selectedDob;
  late BabyGender _selectedGender;
  late bool _isPremature;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.baby.name);
    _bloodTypeCtrl = TextEditingController(text: widget.baby.bloodType ?? '');
    _medicalNotesCtrl = TextEditingController(text: widget.baby.medicalNotes ?? '');
    _birthWeightCtrl = TextEditingController(text: widget.baby.birthWeight?.toString() ?? '');
    _birthHeightCtrl = TextEditingController(text: widget.baby.birthHeight?.toString() ?? '');
    _birthHeadCtrl = TextEditingController(text: widget.baby.birthHeadCircumference?.toString() ?? '');
    _gestationalAgeCtrl = TextEditingController(text: widget.baby.gestationalAge?.toString() ?? '');
    _selectedDob = widget.baby.dateOfBirth;
    _selectedGender = widget.baby.gender;
    _isPremature = widget.baby.isPremature;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bloodTypeCtrl.dispose();
    _medicalNotesCtrl.dispose();
    _birthWeightCtrl.dispose();
    _birthHeightCtrl.dispose();
    _birthHeadCtrl.dispose();
    _gestationalAgeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final updated = widget.baby.copyWith(
        name: _nameCtrl.text.trim(),
        dateOfBirth: _selectedDob,
        gender: _selectedGender,
        bloodType: _bloodTypeCtrl.text.trim().isNotEmpty ? _bloodTypeCtrl.text.trim() : null,
        medicalNotes: _medicalNotesCtrl.text.trim().isNotEmpty ? _medicalNotesCtrl.text.trim() : null,
        birthWeight: double.tryParse(_birthWeightCtrl.text),
        birthHeight: double.tryParse(_birthHeightCtrl.text),
        birthHeadCircumference: double.tryParse(_birthHeadCtrl.text),
        isPremature: _isPremature,
        gestationalAge: int.tryParse(_gestationalAgeCtrl.text),
      );
      await context.read<BabyRepository>().updateBaby(updated);
      if (mounted) {
        AppToast.show(context, message: 'Baby profile updated!', type: ToastType.success);
        context.pop();
      }
    } catch (e) {
      if (mounted) AppToast.show(context, message: 'Failed to update profile', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.d24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded), style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerLow)),
                    const SizedBox(width: AppDimens.d12),
                    Text('Edit Baby Profile', style: AppTextStyles.titleLarge),
                  ],
                ),
                const SizedBox(height: AppDimens.d28),

                // Name
                AppTextField(
                  label: "Baby's Name",
                  hint: "Enter name",
                  controller: _nameCtrl,
                  validator: Validators.name,
                  prefixIcon: const Icon(Icons.child_care_rounded, size: AppDimens.iconMd),
                ),
                const SizedBox(height: AppDimens.d20),

                // Date of birth
                Text('Date of Birth', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppDimens.d8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.d16, vertical: AppDimens.d14),
                    decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: AppColors.onSurfaceVariant, size: AppDimens.iconMd),
                        const SizedBox(width: AppDimens.d12),
                        Text(DateFormat('MMMM d, yyyy').format(_selectedDob), style: AppTextStyles.bodyLarge),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.d20),

                // Gender
                Text('Gender', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppDimens.d8),
                Row(
                  children: [
                    _GenderChip(label: 'Boy', emoji: '👦', isSelected: _selectedGender == BabyGender.male, onTap: () => setState(() => _selectedGender = BabyGender.male)),
                    const SizedBox(width: AppDimens.d12),
                    _GenderChip(label: 'Girl', emoji: '👧', isSelected: _selectedGender == BabyGender.female, onTap: () => setState(() => _selectedGender = BabyGender.female)),
                  ],
                ),
                const SizedBox(height: AppDimens.d20),

                // Blood Type
                AppTextField(
                  label: 'Blood Type',
                  hint: 'e.g. A+, B-, O+',
                  controller: _bloodTypeCtrl,
                  prefixIcon: const Icon(Icons.bloodtype_outlined, size: AppDimens.iconMd),
                ),
                const SizedBox(height: AppDimens.d20),

                // Birth measurements
                Text('Birth Measurements', style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary)),
                const SizedBox(height: AppDimens.d12),
                Row(
                  children: [
                    Expanded(child: AppTextField(label: 'Weight (kg)', hint: 'e.g. 3.2', controller: _birthWeightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: AppDimens.d12),
                    Expanded(child: AppTextField(label: 'Height (cm)', hint: 'e.g. 50', controller: _birthHeightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                const SizedBox(height: AppDimens.d12),
                AppTextField(label: 'Head Circ. (cm)', hint: 'e.g. 34', controller: _birthHeadCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: AppDimens.d20),

                // Premature toggle
                Row(
                  children: [
                    Expanded(
                      child: Text('Premature Birth', style: AppTextStyles.bodyMedium),
                    ),
                    Switch(
                      value: _isPremature,
                      onChanged: (v) => setState(() => _isPremature = v),
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                if (_isPremature) ...[
                  const SizedBox(height: AppDimens.d12),
                  AppTextField(label: 'Gestational Age (weeks)', hint: 'e.g. 36', controller: _gestationalAgeCtrl, keyboardType: TextInputType.number),
                ],
                const SizedBox(height: AppDimens.d20),

                // Medical Notes
                AppTextField(
                  label: 'Medical Notes',
                  hint: 'Any medical conditions, allergies, etc.',
                  controller: _medicalNotesCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: AppDimens.d32),

                AppButton(
                  label: 'Save Changes',
                  onPressed: _isLoading ? null : _save,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppDimens.d16),
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
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: AppDimens.d4),
              Text(label, style: AppTextStyles.labelMedium.copyWith(color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
