import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_info.dart';
import '../../core/strings.dart';
import '../../services/settings_provider.dart';
import '../../services/stats_store.dart';
import '../../services/timer_engine.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final engine = context.read<TimerEngine>();
    final stats = context.watch<StatsStore>();
    final scheme = Theme.of(context).colorScheme;

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
        _sectionTitle(context, tr('时长', 'Duration')),
        _sliderTile(
          context,
          tr('专注时长', 'Focus'),
          settings.focusMin,
          5,
          90,
          17,
          '${settings.focusMin} ${tr('分钟', 'min')}',
          (v) {
            settings.setFocus(v);
            engine.syncIdleDuration();
          },
        ),
        _sliderTile(
          context,
          tr('短休息', 'Short break'),
          settings.breakMin,
          1,
          30,
          29,
          '${settings.breakMin} ${tr('分钟', 'min')}',
          (v) {
            settings.setBreak(v);
            engine.syncIdleDuration();
          },
        ),
        _sliderTile(
          context,
          tr('长休息', 'Long break'),
          settings.longBreakMin,
          5,
          45,
          8,
          '${settings.longBreakMin} ${tr('分钟', 'min')}',
          (v) {
            settings.setLongBreak(v);
            engine.syncIdleDuration();
          },
        ),
        _sliderTile(
          context,
          tr('每几轮长休', 'Sessions before LB'),
          settings.sessionsBeforeLongBreak,
          2,
          8,
          6,
          '${settings.sessionsBeforeLongBreak} ${tr('轮', '')}',
          settings.setSessionsBeforeLongBreak,
        ),
        _sliderTile(
          context,
          tr('每日目标', 'Daily goal'),
          settings.dailyGoalSessions,
          1,
          16,
          15,
          '${settings.dailyGoalSessions} ${tr('个番茄', '')}',
          settings.setGoal,
        ),
        const SizedBox(height: 8),
        _sectionTitle(context, tr('外观', 'Appearance')),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
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
              onSelectionChanged: (s) => settings.setTheme(s.first),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<Lang>(
              segments: [
                ButtonSegment(
                    value: Lang.system,
                    label: Text(tr('跟随系统', 'System'))),
                ButtonSegment(value: Lang.zh, label: const Text('中文')),
                ButtonSegment(value: Lang.en, label: const Text('English')),
              ],
              selected: {S.pref},
              onSelectionChanged: (s) => settings.setLang(s.first),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _sectionTitle(context, tr('行为', 'Behavior')),
        SwitchListTile(
          title: Text(tr('自动开始下一阶段', 'Auto-start next')),
          subtitle: Text(
            tr('完成一个阶段后自动开始下一个',
                'Automatically start the next phase'),
          ),
          value: settings.autoStart,
          onChanged: settings.setAutoStart,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        SwitchListTile(
          title: Text(tr('完成时振动', 'Vibrate on complete')),
          value: settings.vibrateOnComplete,
          onChanged: settings.setVibrate,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const Divider(height: 32),
        _sectionTitle(context, tr('数据', 'Data')),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(tr('导出数据', 'Export data')),
                subtitle: Text(
                  tr('将专注记录复制为 JSON 备份',
                      'Copy focus history as a JSON backup'),
                ),
                onTap: () => _exportData(context, stats),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.download_for_offline_outlined),
                title: Text(tr('导入数据', 'Import data')),
                subtitle: Text(
                  tr('从 JSON 备份恢复专注记录',
                      'Restore focus history from a JSON backup'),
                ),
                onTap: () => _importData(context, stats),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('关于', 'About'),
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(Icons.timer,
                          size: 18, color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 10),
                    Text('ZenFocus 禅注 v$kAppVersion'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tr('开源、无广告、完全本地的专注计时器',
                      'Open-source, ad-free, offline focus timer'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'github.com/wangzi5151/zenfocus',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MIT License',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context, StatsStore stats) async {
    final json = stats.exportJson();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('导出数据', 'Export data')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('备份已复制到剪贴板', 'Backup copied')),
                  ),
                );
              }
            },
            child: Text(tr('复制', 'Copy')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('关闭', 'Close')),
          ),
        ],
      ),
    );
  }

  Future<void> _importData(BuildContext context, StatsStore stats) async {
    final controller = TextEditingController();
    String? error;
    final imported = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(tr('导入数据', 'Import data')),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('粘贴由本应用导出的 JSON 备份。导入会覆盖当前记录。',
                      'Paste a JSON backup exported by this app. Importing replaces current data.'),
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  minLines: 4,
                  maxLines: 8,
                  style: const TextStyle(
                      fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: '{"schema":1,...}',
                    errorText: error,
                    errorMaxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                final text = data?.text;
                if (text != null) {
                  setState(() {
                    controller.text = text;
                    error = null;
                  });
                }
              },
              child: Text(tr('粘贴', 'Paste')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr('取消', 'Cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final ok = await stats.importJson(controller.text);
                if (!ctx.mounted) return;
                if (ok) {
                  Navigator.pop(ctx, true);
                } else {
                  setState(() {
                    error = tr('无法解析备份数据', 'Invalid backup data');
                  });
                }
              },
              child: Text(tr('导入', 'Import')),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (imported == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('数据已导入', 'Data imported'))),
      );
    }
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _sliderTile(
    BuildContext context,
    String title,
    int value,
    int min,
    int max,
    int divisions,
    String display,
    ValueChanged<int> onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text(display,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        )),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions,
              onChanged: (v) => onChanged(v.toInt()),
            ),
          ],
        ),
      ),
    );
  }
}
