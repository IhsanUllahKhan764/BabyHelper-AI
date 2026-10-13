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
import 'package:baby_helper_ai/data/services/who_standards_service.dart';
import 'package:baby_helper_ai/data/models/growth_measurement_model.dart';
import 'package:baby_helper_ai/modules/growth/viewmodels/growth_viewmodel.dart';
import 'package:baby_helper_ai/modules/home/viewmodels/home_viewmodel.dart';

class GrowthPage extends StatefulWidget {
  const GrowthPage({super.key});

  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = context.read<HomeViewModel>().baby;
      if (baby != null) {
        context.read<GrowthViewModel>().loadMeasurements(baby.id, baby: baby);
      }
    });
  }

  Future<void> _deleteMeasurement(GrowthMeasurementModel m) async {
    final baby = context.read<HomeViewModel>().baby;
    if (baby == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Measurement'),
        content: Text('Delete measurement from ${Formatters.dateShort.format(m.date)}?'),
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
      final success = await context.read<GrowthViewModel>().deleteMeasurement(baby.id, m.id);
      if (mounted) {
        AppToast.show(context,
          message: success ? 'Measurement deleted' : 'Failed to delete',
          type: success ? ToastType.success : ToastType.error,
        );
      }
    }
  }

  void _editMeasurement(GrowthMeasurementModel m) {
    context.push(AppRoutes.addMeasurement, extra: m);
  }

  @override
  Widget build(BuildContext context) {
    final growthVm = context.watch<GrowthViewModel>();
    final baby = context.watch<HomeViewModel>().baby;

    return Scaffold(
      appBar: AppBarWidget(
        title: AppStrings.growthTracker,
        onNotificationTap: () => context.push(AppRoutes.notifications),
        onSettingsTap: () => context.push(AppRoutes.settings),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.addMeasurement);
          if (context.mounted && baby != null) {
            growthVm.loadMeasurements(baby.id, baby: baby);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: AppColors.growthAccent,
        foregroundColor: Colors.white,
      ),
      body: growthVm.isLoading
          ? const AppLoader()
          : growthVm.measurements.isEmpty
          ? const AppEmptyState(
              icon: Icons.show_chart_rounded,
              title: 'No measurements yet',
              subtitle:
                  'Add your baby\'s first measurement to start tracking growth',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.d24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WHO Growth Status Banner
                  if (growthVm.overallGrowthStatus != null)
                    _GrowthStatusBanner(
                      isNormal: growthVm.isGrowthNormal,
                      status: growthVm.overallGrowthStatus!,
                      summary: growthVm.growthSummary,
                    ),

                  if (growthVm.overallGrowthStatus != null)
                    const SizedBox(height: AppDimens.d20),

                  // Latest stats
                  if (growthVm.latest != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Weight',
                            value: '${growthVm.latest!.weight} kg',
                            status: WhoStandardsService.getWeightStatus(
                              growthVm.latest!.weightZScore,
                            ),
                            zScore: growthVm.latest!.weightZScore,
                            color: const Color(0xFF0984E3),
                          ),
                        ),
                        const SizedBox(width: AppDimens.d12),
                        Expanded(
                          child: _StatCard(
                            label: 'Height',
                            value: '${growthVm.latest!.height} cm',
                            status: WhoStandardsService.getHeightStatus(
                              growthVm.latest!.heightZScore,
                            ),
                            zScore: growthVm.latest!.heightZScore,
                            color: const Color(0xFF00B894),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.d12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Head',
                            value: '${growthVm.latest!.headCircumference} cm',
                            status: WhoStandardsService.getHeadStatus(
                              growthVm.latest!.headZScore,
                            ),
                            zScore: growthVm.latest!.headZScore,
                            color: const Color(0xFF6C5CE7),
                          ),
                        ),
                        const SizedBox(width: AppDimens.d12),
                        Expanded(
                          child: _StatCard(
                            label: 'BMI',
                            value: Formatters.formatDecimal(
                              growthVm.latest!.bmi,
                            ),
                            status: 'Calculated',
                            zScore: growthVm.latest!.bmiZScore,
                            color: const Color(0xFFEE5A24),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppDimens.d28),

                  // Weight chart
                  if (growthVm.measurements.length > 1) ...[
                    Text('Weight Trend', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimens.d16),
                    AppCard(
                      color: AppColors.surfaceContainerLow,
                      boxShadow: const [],
                      child: SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppColors.outlineVariant.withValues(
                                  alpha: 0.2,
                                ),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (v, meta) => Text(
                                    '${v.toStringAsFixed(0)}kg',
                                    style: AppTextStyles.caption,
                                  ),
                                ),
                              ),
                              bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: growthVm.measurements.reversed
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => FlSpot(
                                        e.key.toDouble(),
                                        e.value.weight,
                                      ),
                                    )
                                    .toList(),
                                isCurved: true,
                                color: const Color(0xFF0984E3),
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (_, _, _, _) =>
                                      FlDotCirclePainter(
                                        radius: 4,
                                        color: const Color(0xFF0984E3),
                                        strokeColor: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(
                                    0xFF0984E3,
                                  ).withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimens.d20),

                    // Height chart
                    Text('Height Trend', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppDimens.d16),
                    AppCard(
                      color: AppColors.surfaceContainerLow,
                      boxShadow: const [],
                      child: SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 5,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppColors.outlineVariant.withValues(alpha: 0.2),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (v, meta) => Text(
                                    '${v.toStringAsFixed(0)}cm',
                                    style: AppTextStyles.caption,
                                  ),
                                ),
                              ),
                              bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: growthVm.measurements.reversed
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(e.key.toDouble(), e.value.height))
                                    .toList(),
                                isCurved: true,
                                color: const Color(0xFF00B894),
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                                    radius: 4,
                                    color: const Color(0xFF00B894),
                                    strokeColor: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFF00B894).withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppDimens.d28),

                  // History list with swipe-to-delete and tap-to-edit
                  Text('Measurement History', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppDimens.d12),
                  ...growthVm.measurements.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.d8),
                      child: Dismissible(
                        key: Key(m.id),
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
                          await _deleteMeasurement(m);
                          return false; // We handle removal via viewmodel
                        },
                        child: GestureDetector(
                          onTap: () => _editMeasurement(m),
                          child: AppCard(
                            color: AppColors.surfaceContainerLow,
                            boxShadow: const [],
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppDimens.d8),
                                  decoration: BoxDecoration(
                                    color: AppColors.growthAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                  ),
                                  child: const Icon(
                                    Icons.straighten,
                                    size: 20,
                                    color: AppColors.growthAccent,
                                  ),
                                ),
                                const SizedBox(width: AppDimens.d12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${m.weight}kg • ${m.height}cm • HC ${m.headCircumference}cm',
                                        style: AppTextStyles.labelLarge,
                                      ),
                                      Text(
                                        Formatters.dateShort.format(m.date),
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (m.weightZScore != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: WhoStandardsService.hasWarning(m.weightZScore)
                                          ? AppColors.warning.withValues(alpha: 0.15)
                                          : AppColors.success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                                    ),
                                    child: Text(
                                      Formatters.formatPercentile(m.weightZScore!),
                                      style: AppTextStyles.caption.copyWith(
                                        color: WhoStandardsService.hasWarning(m.weightZScore)
                                            ? AppColors.warning
                                            : AppColors.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: AppDimens.d4),
                                const Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }
}

/// WHO Growth Status Banner — displays Normal/Abnormal prominently
class _GrowthStatusBanner extends StatelessWidget {
  final bool isNormal;
  final String status;
  final String summary;

  const _GrowthStatusBanner({
    required this.isNormal,
    required this.status,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.d20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNormal
              ? [const Color(0xFF00B894), const Color(0xFF55EFC4)]
              : [const Color(0xFFE17055), const Color(0xFFFF7675)],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        boxShadow: [
          BoxShadow(
            color: (isNormal ? const Color(0xFF00B894) : const Color(0xFFE17055))
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.d12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNormal ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppDimens.d16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.d4),
                Text(
                  summary,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String status;
  final double? zScore;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.status,
    this.zScore,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasWarning = WhoStandardsService.hasWarning(zScore);
    return AppCard(
      color: AppColors.surfaceContainerLow,
      boxShadow: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimens.d4),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
          const SizedBox(height: AppDimens.d4),
          Row(
            children: [
              if (hasWarning)
                const Icon(
                  Icons.warning_amber,
                  size: 14,
                  color: AppColors.warning,
                ),
              if (hasWarning) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: hasWarning ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          if (zScore != null) ...[
            const SizedBox(height: AppDimens.d4),
            Text(
              'z: ${zScore!.toStringAsFixed(2)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
