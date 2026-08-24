import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/strings.dart';
import '../../services/stats_store.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsStore>();
    final scheme = Theme.of(context).colorScheme;
    final last7 = stats.last7Days();
    final rawMax = last7.isEmpty
        ? 1
        : last7.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = math.max(30, ((rawMax + 29) ~/ 30) * 30).toDouble();

    const zhLabels = ['一', '二', '三', '四', '五', '六', '日'];

    final cards = [
      _statCard(
        context,
        tr('总时长', 'Total'),
        '${(stats.totalMinutes / 60).toStringAsFixed(1)} ${tr('小时', 'hrs')}',
        Icons.schedule,
      ),
      _statCard(
        context,
        tr('总番茄', 'Pomodoros'),
        '${stats.totalSessions}',
        Icons.local_fire_department,
      ),
      _statCard(
        context,
        tr('连击', 'Streak'),
        '${stats.streak()} ${tr('天', 'days')}',
        Icons.emoji_events,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 8),
            Expanded(child: cards[1]),
            const SizedBox(width: 8),
            Expanded(child: cards[2]),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('最近 7 天', 'Last 7 days'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barGroups: List.generate(7, (i) {
                        final day = last7[i].key;
                        final now = DateTime.now();
                        final isToday = day.year == now.year &&
                            day.month == now.month &&
                            day.day == now.day;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: last7[i].value.toDouble(),
                              width: 16,
                              borderRadius: BorderRadius.circular(6),
                              color: isToday
                                  ? scheme.tertiary
                                  : scheme.primary.withOpacity(0.7),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= 7) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  zhLabels[day.weekday - 1],
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 30,
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
      BuildContext context, String title, String value, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: scheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
