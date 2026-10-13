import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:baby_helper_ai/app/routes/app_routes.dart';
import 'package:baby_helper_ai/core/constants/app_colors.dart';
import 'package:baby_helper_ai/core/constants/app_dimens.dart';
import 'package:baby_helper_ai/core/constants/app_strings.dart';
import 'package:baby_helper_ai/core/constants/app_text_styles.dart';
import 'package:baby_helper_ai/core/widgets/app_bar_widget.dart';
import 'package:baby_helper_ai/core/widgets/app_card.dart';
import 'package:baby_helper_ai/core/widgets/app_loader.dart';
import 'package:baby_helper_ai/core/widgets/app_empty_state.dart';
import 'package:baby_helper_ai/core/widgets/app_toast.dart';
import 'package:baby_helper_ai/core/utils/formatters.dart';
import 'package:baby_helper_ai/modules/sleep/viewmodels/sleep_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = context.read<HomeViewModel>().baby;
      if (baby != null) context.read<SleepViewModel>().loadSessions(baby.id);
    });
  }

  Future<void> _deleteSession(String sessionId) async {
    final baby = context.read<HomeViewModel>().baby;
    if (baby == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Remove this sleep session?'),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<SleepViewModel>().deleteSession(baby.id, sessionId);
      if (mounted) {
        AppToast.show(context,
          message: success ? 'Session deleted' : 'Failed to delete',
          type: success ? ToastType.success : ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sleepVm = context.watch<SleepViewModel>();
    final baby = context.watch<HomeViewModel>().baby;

    return Scaffold(
      appBar: AppBarWidget(
        title: AppStrings.sleepMonitor,
        onNotificationTap: () => context.push(AppRoutes.notifications),
        onSettingsTap: () => context.push(AppRoutes.settings),
      ),
      body: sleepVm.isLoading
          ? const AppLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.d24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today summary hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.d24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFA29BFE), Color(0xFF6C5CE7)]),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      boxShadow: [BoxShadow(color: const Color(0xFF6C5CE7).withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.bedtime_rounded, size: 40, color: Colors.white),
                        const SizedBox(height: AppDimens.d8),
                        Text('Today\'s Sleep', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                        Text(
                          '${sleepVm.todayTotalHours.toStringAsFixed(1)} hours',
                          style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${sleepVm.todayNapCount} session${sleepVm.todayNapCount != 1 ? 's' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.d20),

                  // Log Sleep Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await context.push(AppRoutes.addSleepSession);
                        if (context.mounted && baby != null) {
                          sleepVm.loadSessions(baby.id);
                          context.read<HomeViewModel>().loadDashboard();
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Log Sleep Session'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sleepAccent,
                        padding: const EdgeInsets.symmetric(vertical: AppDimens.d16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimens.d24),

                  // Statistics row
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.access_time_filled,
                          label: 'Longest',
                          value: '${sleepVm.longestStretchHours.toStringAsFixed(1)}h',
                          color: const Color(0xFF00B894),
                        ),
                      ),
                      const SizedBox(width: AppDimens.d12),
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.trending_up,
                          label: 'Avg/Session',
                          value: '${sleepVm.avgSessionHours.toStringAsFixed(1)}h',
                          color: const Color(0xFF0984E3),
                        ),
                      ),
                      const SizedBox(width: AppDimens.d12),
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.calendar_view_week,
                          label: 'Week Avg',
                          value: '${sleepVm.weekAvgHoursPerDay.toStringAsFixed(1)}h/d',
                          color: const Color(0xFFE17055),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.d28),

                  // Weekly chart
                  Text('This Week', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppDimens.d16),
                  AppCard(
                    color: AppColors.surfaceContainerLow,
                    boxShadow: const [],
                    child: SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 16,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final trends = sleepVm.weeklyTrends;
                                final day = trends[group.x]['day'] as String;
                                return BarTooltipItem(
                                  '$day\n${rod.toY.toStringAsFixed(1)}h',
                                  AppTextStyles.caption.copyWith(color: Colors.white),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, meta) {
                                  final trends = sleepVm.weeklyTrends;
                                  if (v.toInt() < trends.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(trends[v.toInt()]['day'] as String, style: AppTextStyles.caption),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 4,
                                getTitlesWidget: (v, meta) => Text('${v.toInt()}h', style: AppTextStyles.caption),
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 4,
                            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.outlineVariant.withValues(alpha: 0.2), strokeWidth: 1),
                          ),
                          barGroups: sleepVm.weeklyTrends.asMap().entries.map((e) {
                            final hours = e.value['hours'] as double;
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: hours,
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Color(0xFFA29BFE), Color(0xFF6C5CE7)],
                                  ),
                                  width: 14,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimens.d28),

                  // Sleep Tips
                  if (baby != null) ...[
                    Text('Sleep Tips', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimens.d4),
                    Text('For ${baby.ageInMonths} months old', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: AppDimens.d12),
                    ...sleepVm.getSleepTips(baby.ageInMonths).take(4).map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.d8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimens.d16),
                        decoration: BoxDecoration(
                          color: AppColors.sleepAccent.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          border: Border.all(color: AppColors.sleepAccent.withValues(alpha: 0.15)),
                        ),
                        child: Text(tip, style: AppTextStyles.bodySmall.copyWith(height: 1.5)),
                      ),
                    )),
                  ],

                  const SizedBox(height: AppDimens.d28),

                  // Session list with swipe-to-delete
                  Text('Recent Sessions', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppDimens.d12),

                  if (sleepVm.sessions.isEmpty)
                    const AppEmptyState(
                      icon: Icons.bedtime_outlined,
                      title: 'No sleep sessions',
                      subtitle: 'Log your baby\'s first sleep session',
                    )
                  else
                    ...sleepVm.sessions.take(10).map((session) => Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.d8),
                      child: Dismissible(
                        key: Key(session.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppDimens.d20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          ),
                          child: const Icon(Icons.delete_outline, color: AppColors.error),
                        ),
                        confirmDismiss: (_) async {
                          await _deleteSession(session.id);
                          return false;
                        },
                        child: AppCard(
                          color: AppColors.surfaceContainerLow,
                          boxShadow: const [],
                          child: Row(
                            children: [
                              Text(session.qualityEmoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: AppDimens.d12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${Formatters.time12h.format(session.startTime)} - ${Formatters.time12h.format(session.endTime)}',
                                      style: AppTextStyles.labelLarge,
                                    ),
                                    Text(
                                      '${Formatters.formatDuration(session.duration)} • ${session.qualityLabel}',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                                    ),
                                    if (session.notes != null && session.notes!.isNotEmpty)
                                      Text(session.notes!, style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Text(
                                Formatters.dayMonth.format(session.startTime),
                                style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),

                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }
}

/// Mini statistic card for the sleep statistics row
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.d14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppDimens.d4),
          Text(value, style: AppTextStyles.labelLarge.copyWith(color: color, fontWeight: FontWeight.w700)),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }
}
