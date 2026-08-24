import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../services/stats_store.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsStore>();
    final history = stats.history;
    final scheme = Theme.of(context).colorScheme;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: scheme.surfaceContainerHighest),
            const SizedBox(height: 16),
            Text(
              tr('暂无记录', 'No records yet'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              tr('完成你的第一次专注吧', 'Complete your first focus session'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    final grouped = <String, List<SessionRecord>>{};
    for (final r in history) {
      final key = StatsStore.keyOf(r.time);
      grouped.putIfAbsent(key, () => []).add(r);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: dates.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              tr('专注记录', 'Session history'),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }

        final dateKey = dates[index - 1];
        final daySessions = grouped[dateKey]!;
        final dayTotal = daySessions.fold<int>(0, (a, b) => a + b.minutes);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Text(
                '${daySessions.length}',
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              _formatDate(dateKey),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${dayTotal} ${tr('分钟', 'min')} · ${daySessions.length} ${tr('个番茄', 'sessions')}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            children: daySessions.map((r) {
              final hh = r.time.hour.toString().padLeft(2, '0');
              final mm = r.time.minute.toString().padLeft(2, '0');
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.circle,
                  size: 8,
                  color: r.completed ? scheme.primary : scheme.error,
                ),
                title: Text(
                  '$hh:$mm',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  '${r.minutes} ${tr('分钟', 'min')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _formatDate(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return key;
    final now = DateTime.now();
    final d = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(d).inDays;

    if (diff == 0) return tr('今天', 'Today');
    if (diff == 1) return tr('昨天', 'Yesterday');
    if (diff == 2) return tr('前天', 'The day before');
    return '${parts[1]}/${parts[2]}';
  }
}
