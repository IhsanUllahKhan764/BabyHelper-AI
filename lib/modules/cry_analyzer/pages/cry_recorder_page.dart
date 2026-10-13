import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baby_helper_ai/app/routes/app_routes.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_strings.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_bar_widget.dart';
import 'package:baby_helper_ai/core/widgets/app_button.dart';
import 'package:baby_helper_ai/modules/cry_analyzer/viewmodels/cry_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';

import 'package:intl/intl.dart';

class CryRecorderPage extends StatefulWidget {
  const CryRecorderPage({super.key});

  @override
  State<CryRecorderPage> createState() => _CryRecorderPageState();
}

class _CryRecorderPageState extends State<CryRecorderPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVm = context.read<HomeViewModel>();
      if (homeVm.baby != null) {
        context.read<CryViewModel>().loadHistory(homeVm.baby!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cryVm = context.watch<CryViewModel>();
    final homeVm = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBarWidget(
        title: AppStrings.cryAnalyzer,
        onNotificationTap: () => context.push(AppRoutes.notifications),
        onSettingsTap: () => context.push(AppRoutes.settings),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.d24, vertical: AppDimens.d24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Main recording button
              GestureDetector(
                onTap: () async {
                  if (cryVm.isRecording) {
                    final result = await cryVm.stopAndAnalyze();
                    if (result != null && homeVm.baby != null) {
                      // Removed auto-save; users must manually save from the Result page
                      if (context.mounted) {
                        context.push(AppRoutes.cryResult, extra: result);
                      }
                    }
                  } else if (cryVm.isNoAudioDetected || cryVm.state == CryRecordingState.error) {
                    // Don't start recording when in error/silence state; use retry button
                  } else {
                    await cryVm.startRecording();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: cryVm.isRecording ? 180 : 160,
                  height: cryVm.isRecording ? 180 : 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: cryVm.isRecording
                        ? const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)])
                        : cryVm.isNoAudioDetected
                            ? const LinearGradient(colors: [Color(0xFFB2BEC3), Color(0xFF636E72)])
                            : AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (cryVm.isRecording ? const Color(0xFFFF6B6B) : AppColors.primary).withValues(alpha: 0.4),
                        blurRadius: cryVm.isRecording ? 40 : 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: cryVm.isAnalyzing
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Icon(
                          cryVm.isRecording
                              ? Icons.stop_rounded
                              : cryVm.isNoAudioDetected
                                  ? Icons.mic_off_rounded
                                  : Icons.mic_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                ),
              ),

              const SizedBox(height: AppDimens.d32),

              // Status text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  cryVm.isRecording
                      ? AppStrings.recording
                      : cryVm.isAnalyzing
                          ? AppStrings.analyzing
                          : cryVm.isNoAudioDetected
                              ? 'No Audio Detected'
                              : AppStrings.tapToRecord,
                  key: ValueKey(cryVm.state),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: cryVm.isRecording
                        ? AppColors.secondary
                        : cryVm.isNoAudioDetected
                            ? AppColors.warning
                            : AppColors.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.d8),

              if (cryVm.isRecording)
                Text(
                  'Tap the button to stop and analyze',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),

              if (!cryVm.isRecording && !cryVm.isAnalyzing && !cryVm.isNoAudioDetected && cryVm.error == null)
                Text(
                  'Record your baby\'s cry for at least 3 seconds',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 40),

              // Waveform animation placeholder
              if (cryVm.isRecording)
                _WaveformAnimation(),

              const SizedBox(height: 20),

              // No Audio Detected display
              if (cryVm.isNoAudioDetected) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimens.d20),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mic_off_rounded, color: AppColors.warning, size: 40),
                      const SizedBox(height: AppDimens.d12),
                      Text(
                        cryVm.silenceMessage ?? 'No audio detected',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning),
                      ),
                      const SizedBox(height: AppDimens.d8),
                      Text(
                        'Make sure your baby\'s cry is audible and the microphone is not blocked.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.d16),
                AppButton(
                  label: 'Retry',
                  style: AppButtonStyle.primary,
                  onPressed: () => cryVm.reset(),
                ),
              ],

              // Error display
              if (cryVm.error != null && !cryVm.isNoAudioDetected) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimens.d16),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: AppDimens.d12),
                      Expanded(child: Text(cryVm.error!.message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.d16),
                AppButton(label: 'Try Again', style: AppButtonStyle.secondary, onPressed: () => cryVm.reset()),
              ],

              // Recent Analysis Section
              if (cryVm.history.isNotEmpty && !cryVm.isRecording && !cryVm.isAnalyzing) ...[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recent Analysis', style: AppTextStyles.titleSmall),
                ),
                const SizedBox(height: AppDimens.d16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cryVm.history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimens.d12),
                  itemBuilder: (context, index) {
                    final cry = cryVm.history[index];
                    return Container(
                      padding: const EdgeInsets.all(AppDimens.d16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimens.d12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mic, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: AppDimens.d16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cry.categoryLabel,
                                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.onSurface),
                                ),
                                const SizedBox(height: AppDimens.d4),
                                Text(
                                  DateFormat('MMM d, h:mm a').format(cry.timestamp),
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(cry.confidence * 100).round()}%',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimens.d16),
              ],
              
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveformAnimation extends StatefulWidget {
  @override
  State<_WaveformAnimation> createState() => _WaveformAnimationState();
}

class _WaveformAnimationState extends State<_WaveformAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(20, (i) {
              final phase = (_controller.value + i * 0.05) % 1.0;
              final height = 10 + 40 * (0.5 + 0.5 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2));
              return Container(
                width: 3,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
