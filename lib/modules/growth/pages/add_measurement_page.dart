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
import 'package:baby_helper_ai/data/models/growth_measurement_model.dart';
import 'package:baby_helper_ai/modules/growth/viewmodels/growth_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';
import 'package:intl/intl.dart';

class AddMeasurementPage extends StatefulWidget {
  final GrowthMeasurementModel? existingMeasurement;

  const AddMeasurementPage({super.key, this.existingMeasurement});

  @override
  State<AddMeasurementPage> createState() => _AddMeasurementPageState();
}

class _AddMeasurementPageState extends State<AddMeasurementPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _headCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool get _isEditMode => widget.existingMeasurement != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final m = widget.existingMeasurement!;
      _weightCtrl.text = m.weight.toString();
      _heightCtrl.text = m.height.toString();
      _headCtrl.text = m.headCircumference.toString();
      _selectedDate = m.date;
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _headCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final homeVm = context.read<HomeViewModel>();
    final growthVm = context.read<GrowthViewModel>();
    final baby = homeVm.baby;
    if (baby == null) {
      AppToast.show(context, message: 'Please set up baby profile first', type: ToastType.warning);
      return;
    }

    bool success;
    if (_isEditMode) {
      success = await growthVm.updateMeasurement(
        baby.id,
        baby,
        widget.existingMeasurement!,
        height: double.parse(_heightCtrl.text),
        weight: double.parse(_weightCtrl.text),
        headCircumference: double.parse(_headCtrl.text),
        date: _selectedDate,
      );
    } else {
      success = await growthVm.addMeasurement(
        baby.id,
        baby,
        height: double.parse(_heightCtrl.text),
        weight: double.parse(_weightCtrl.text),
        headCircumference: double.parse(_headCtrl.text),
        date: _selectedDate,
      );
    }

    if (!mounted) return;
    if (success) {
      AppToast.show(context,
        message: _isEditMode ? 'Measurement updated!' : 'Measurement saved!',
        type: ToastType.success,
      );
      context.pop();
    } else if (growthVm.error != null) {
      AppToast.show(context, message: growthVm.error!.message, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final growthVm = context.watch<GrowthViewModel>();

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
                    Text(_isEditMode ? 'Edit Measurement' : 'Add Measurement', style: AppTextStyles.titleLarge),
                  ],
                ),
                const SizedBox(height: AppDimens.d32),

                // Date picker
                Text('Date', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
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
                        Text(DateFormat('MMMM d, yyyy').format(_selectedDate), style: AppTextStyles.bodyLarge),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.d24),

                AppTextField(
                  label: 'Weight (kg)',
                  hint: 'e.g. 7.5',
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => Validators.positiveNumber(v, 'Weight'),
                  prefixIcon: const Icon(Icons.monitor_weight_outlined, size: AppDimens.iconMd),
                ),
                const SizedBox(height: AppDimens.d20),

                AppTextField(
                  label: 'Height (cm)',
                  hint: 'e.g. 68.0',
                  controller: _heightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => Validators.positiveNumber(v, 'Height'),
                  prefixIcon: const Icon(Icons.straighten_outlined, size: AppDimens.iconMd),
                ),
                const SizedBox(height: AppDimens.d20),

                AppTextField(
                  label: 'Head Circumference (cm)',
                  hint: 'e.g. 43.0',
                  controller: _headCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => Validators.positiveNumber(v, 'Head circumference'),
                  prefixIcon: const Icon(Icons.circle_outlined, size: AppDimens.iconMd),
                ),

                const SizedBox(height: AppDimens.d40),

                AppButton(
                  label: _isEditMode ? 'Update Measurement' : 'Save Measurement',
                  onPressed: growthVm.isLoading ? null : _save,
                  isLoading: growthVm.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
