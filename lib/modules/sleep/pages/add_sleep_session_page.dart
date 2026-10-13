import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_button.dart';
import 'package:baby_helper_ai/core/widgets/app_toast.dart';
import 'package:baby_helper_ai/data/models/sleep_session_model.dart';
import 'package:baby_helper_ai/modules/sleep/viewmodels/sleep_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';

class AddSleepSessionPage extends StatefulWidget {
  const AddSleepSessionPage({super.key});

  @override
  State<AddSleepSessionPage> createState() => _AddSleepSessionPageState();
}

class _AddSleepSessionPageState extends State<AddSleepSessionPage> {
  TimeOfDay _startTime = TimeOfDay.now().replacing(
    hour: (TimeOfDay.now().hour - 2).clamp(0, 23),
  );
  TimeOfDay _endTime = TimeOfDay.now();
  final DateTime _selectedDate = DateTime.now();
  SleepQuality _quality = SleepQuality.good;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    final baby = context.read<HomeViewModel>().baby;
    if (baby == null) {
      AppToast.show(
        context,
        message: 'Set up baby profile first',
        type: ToastType.warning,
      );
      return;
    }

    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    var end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    if (end.isBefore(start)) end = end.add(const Duration(days: 1));

    final sleepVm = context.read<SleepViewModel>();
    final success = await sleepVm.addSession(
      baby.id,
      startTime: start,
      endTime: end,
      quality: _quality,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
    );

    if (!mounted) return;
    if (success) {
      AppToast.show(
        context,
        message: 'Sleep session saved!',
        type: ToastType.success,
      );
      context.pop();
    } else if (sleepVm.error != null) {
      AppToast.show(
        context,
        message: sleepVm.error!.message,
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sleepVm = context.watch<SleepViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.d24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLow,
                    ),
                  ),
                  const SizedBox(width: AppDimens.d12),
                  Text('Log Sleep Session', style: AppTextStyles.titleLarge),
                ],
              ),
              const SizedBox(height: AppDimens.d32),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: 'Start Time',
                      time: _startTime,
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: AppDimens.d16),
                  Expanded(
                    child: _TimePicker(
                      label: 'End Time',
                      time: _endTime,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.d24),

              // Quality selector
              Text(
                'Sleep Quality',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimens.d12),
              Row(
                children: SleepQuality.values.map((q) {
                  final isSelected = _quality == q;
                  final emoji = switch (q) {
                    SleepQuality.excellent => '😊',
                    SleepQuality.good => '🙂',
                    SleepQuality.fair => '😐',
                    SleepQuality.poor => '😟',
                  };
                  final label = switch (q) {
                    SleepQuality.excellent => 'Great',
                    SleepQuality.good => 'Good',
                    SleepQuality.fair => 'Fair',
                    SleepQuality.poor => 'Poor',
                  };
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _quality = q),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimens.d12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.sleepAccent.withValues(alpha: 0.15)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusMd,
                            ),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.sleepAccent,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: AppDimens.d4),
                              Text(
                                label,
                                style: AppTextStyles.caption.copyWith(
                                  color: isSelected
                                      ? AppColors.sleepAccent
                                      : AppColors.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimens.d24),

              // Notes
              Text(
                'Notes (optional)',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimens.d8),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any observations...',
                ),
              ),

              const SizedBox(height: AppDimens.d40),

              AppButton(
                label: 'Save Session',
                onPressed: sleepVm.isLoading ? null : _save,
                isLoading: sleepVm.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppDimens.d8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.d16,
              vertical: AppDimens.d14,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: AppDimens.iconMd,
                ),
                const SizedBox(width: AppDimens.d8),
                Text(time.format(context), style: AppTextStyles.bodyLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
