import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../services/stats_store.dart';

class Achievement {
  final String titleZh;
  final String titleEn;
  final String descZh;
  final String descEn;
  final IconData icon;
  final bool Function(StatsStore) unlocked;

  const Achievement({
    required this.titleZh,
    required this.titleEn,
    required this.descZh,
    required this.descEn,
    required this.icon,
    required this.unlocked,
  });

  String title() => tr(titleZh, titleEn);
  String desc() => tr(descZh, descEn);
}

final List<Achievement> _achievements = [
  Achievement(
    titleZh: '初次专注',
    titleEn: 'First Focus',
    descZh: '完成第一次专注',
    descEn: 'Complete your first session',
    icon: Icons.flag,
    unlocked: (s) => s.totalSessions >= 1,
  ),
  Achievement(
    titleZh: '小试牛刀',
    titleEn: 'Getting Started',
    descZh: '完成 10 次专注',
    descEn: 'Complete 10 sessions',
    icon: Icons.military_tech,
    unlocked: (s) => s.totalSessions >= 10,
  ),
  Achievement(
    titleZh: '百炼成钢',
    titleEn: 'Centurion',
    descZh: '完成 100 次专注',
    descEn: 'Complete 100 sessions',
    icon: Icons.workspace_premium,
    unlocked: (s) => s.totalSessions >= 100,
  ),
  Achievement(
    titleZh: '小时之约',
    titleEn: 'One Hour Club',
    descZh: '累计专注 1 小时',
    descEn: 'Reach 1 hour total',
    icon: Icons.schedule,
    unlocked: (s) => s.totalMinutes >= 60,
  ),
  Achievement(
    titleZh: '一日五餐',
    titleEn: 'Five a Day',
    descZh: '单日完成 5 次专注',
    descEn: '5 sessions in one day',
    icon: Icons.event_available,
    unlocked: (s) => s.maxSessionsPerDay >= 5,
  ),
  Achievement(
    titleZh: '七日之约',
    titleEn: 'Week Warrior',
    descZh: '连续 7 天专注',
    descEn: '7-day streak',
    icon: Icons.calendar_month,
    unlocked: (s) => s.streak() >= 7,
  ),
];

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsStore>();
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          tr('成就', 'Achievements'),
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: _achievements.map((a) {
            final done = a.unlocked(stats);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: done
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      child: Icon(
                        a.icon,
                        color: done
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a.title(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.desc(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
