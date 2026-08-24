import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../services/settings_provider.dart';
import '../../services/timer_engine.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final engine = context.read<TimerEngine>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          tr('设置', 'Settings'),
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _section(
          context,
          tr('专注时长', 'Focus duration'),
          Slider(
            value: settings.focusMin.toDouble(),
            min: 5,
            max: 90,
            divisions: 17,
            label: '${settings.focusMin} ${tr('分钟', 'min')}',
            onChanged: (v) {
              settings.setFocus(v.toInt());
              engine.syncIdleDuration();
            },
          ),
          '${settings.focusMin} ${tr('分钟', 'min')}',
        ),
        _section(
          context,
          tr('休息时长', 'Break duration'),
          Slider(
            value: settings.breakMin.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '${settings.breakMin} ${tr('分钟', 'min')}',
            onChanged: (v) {
              settings.setBreak(v.toInt());
              engine.syncIdleDuration();
            },
          ),
          '${settings.breakMin} ${tr('分钟', 'min')}',
        ),
        _section(
          context,
          tr('每日目标', 'Daily goal'),
          Slider(
            value: settings.dailyGoalSessions.toDouble(),
            min: 1,
            max: 16,
            divisions: 15,
            label: '${settings.dailyGoalSessions} ${tr('个', '')}',
            onChanged: (v) => settings.setGoal(v.toInt()),
          ),
          '${settings.dailyGoalSessions} ${tr('个番茄', 'pomodoros')}',
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('外观', 'Appearance'),
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(tr('自动', 'Auto'))),
                    ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(tr('浅色', 'Light'))),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(tr('深色', 'Dark'))),
                  ],
                  selected: {settings.themeMode},
                  onSelected: (s) => settings.setTheme(s.first),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('语言', 'Language'),
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<Lang>(
                  segments: [
                    ButtonSegment(
                        value: Lang.system,
                        label: Text(tr('跟随系统', 'System'))),
                    ButtonSegment(
                        value: Lang.zh, label: const Text('中文')),
                    ButtonSegment(
                        value: Lang.en, label: const Text('English')),
                  ],
                  selected: {S.pref},
                  onSelected: (s) => settings.setLang(s.first),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(tr('自动开始下一阶段', 'Auto-start next phase')),
          subtitle: Text(
            tr('专注结束自动开始休息，反之亦然', 'Automatically start the next phase'),
          ),
          value: settings.autoStart,
          onChanged: settings.setAutoStart,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const Divider(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('关于', 'About'),
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text('ZenFocus ${tr('禅注', '')} v1.0.0'),
                const SizedBox(height: 4),
                Text(
                  tr('开源、无广告、完全本地的专注计时器',
                      'Open-source, ad-free, offline focus timer'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'github.com/wangzi5151/zenfocus',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MIT License',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(
      BuildContext context, String title, Widget control, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text(value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        )),
              ],
            ),
            control,
          ],
        ),
      ),
    );
  }
}
