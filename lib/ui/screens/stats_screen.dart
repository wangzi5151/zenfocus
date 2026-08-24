import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/strings.dart';
import '../../services/stats_store.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _showWeekly = true;

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsStore>();
    final scheme = Theme.of(context).colorScheme;

    final data = _showWeekly ? stats.last7Days() : stats.last30Days();
    final rawMax = data.isEmpty
        ? 1
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = math.max(30, ((rawMax + 29) ~/ 30) * 30).toDouble();

    const zhWeekLabels = ['一', '二', '三', '四', '五', '六', '日'];

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
        '${stats.streak()} ${tr('天', 'd')}',
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
        const SizedBox(height: 12),
        Row(
          children: [
            _summaryChip(
                context, tr('本周', 'Week'), '${stats.weekMinutes()} ${tr('分钟', 'min')}', scheme.primary),
            const SizedBox(width: 8),
            _summaryChip(
                context, tr('本月', 'Month'), '${stats.monthMinutes()} ${tr('分钟', 'min')}', scheme.tertiary),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tr('专注时长', 'Focus time'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                            value: true, label: Text(tr('周', 'Week'))),
                        ButtonSegment(
                            value: false, label: Text(tr('月', 'Month'))),
                      ],
                      selected: {_showWeekly},
                      onSelectionChanged: (s) => setState(() => _showWeekly = s.first),
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barGroups: List.generate(data.length, (i) {
                        final day = data[i].key;
                        final now = DateTime.now();
                        final isToday = day.year == now.year &&
                            day.month == now.month &&
                            day.day == now.day;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: data[i].value.toDouble(),
                              width: _showWeekly ? 16 : 6,
                              borderRadius: BorderRadius.circular(4),
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
                              if (idx < 0 || idx >= data.length) {
                                return const SizedBox.shrink();
                              }
                              if (_showWeekly) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    zhWeekLabels[data[idx].key.weekday - 1],
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                );
                              }
                              if (idx % 5 == 0 || idx == data.length - 1) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${data[idx].key.month}/${data[idx].key.day}',
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
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

  Widget _summaryChip(
      BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.labelSmall),
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      BuildContext context, String title, String value, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: scheme.primary, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(title, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
