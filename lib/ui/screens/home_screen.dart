import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../services/timer_engine.dart';
import '../../services/settings_provider.dart';
import '../../services/stats_store.dart';
import '../../services/noise_player.dart';
import '../widgets/circle_timer_painter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _soundIcons = {
    AmbientSound.brownNoise: Icons.noise_aware,
    AmbientSound.whiteNoise: Icons.graphic_eq,
    AmbientSound.rain: Icons.cloud,
    AmbientSound.forest: Icons.forest,
    AmbientSound.deepFocus: Icons.meditation,
  };

  static const _soundLabels = {
    AmbientSound.brownNoise: ('棕噪', 'Brown'),
    AmbientSound.whiteNoise: ('白噪', 'White'),
    AmbientSound.rain: ('雨声', 'Rain'),
    AmbientSound.forest: ('森林', 'Forest'),
    AmbientSound.deepFocus: ('深潜', 'Deep'),
  };

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<TimerEngine>();
    final settings = context.watch<SettingsProvider>();
    final stats = context.watch<StatsStore>();
    final scheme = Theme.of(context).colorScheme;

    final mm = (engine.remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (engine.remaining % 60).toString().padLeft(2, '0');

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text(
                  tr('禅注', 'ZenFocus'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 16, color: scheme.onSecondaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        '${stats.streak()} ${tr('天', 'd')}',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: scheme.onSecondaryContainer,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (engine.sessionCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${tr('本轮', 'This run')}: ${engine.sessionCount} ${tr('个番茄', 'pomodoros')}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: DialPainter(
                    progress: engine.progress,
                    isFocus: engine.isFocus,
                    color: engine.isLongRest
                        ? scheme.tertiary
                        : engine.isFocus
                            ? scheme.primary
                            : scheme.secondary,
                    trackColor: scheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          engine.phaseLabel,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: engine.isFocus
                                        ? scheme.primary
                                        : scheme.tertiary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$mm:$ss',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: engine.reset,
                icon: const Icon(Icons.replay),
              ),
              const SizedBox(width: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(140, 52),
                ),
                onPressed: engine.toggle,
                icon:
                    Icon(engine.running ? Icons.pause : Icons.play_arrow),
                label: Text(
                  engine.running ? tr('暂停', 'Pause') : tr('开始', 'Start'),
                ),
              ),
              const SizedBox(width: 24),
              IconButton.filledTonal(
                onPressed: engine.skip,
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            secondary: const Icon(Icons.music_note),
            title: Text(tr('环境音效', 'Ambient sound')),
            value: settings.noiseOn,
            onChanged: (v) {
              settings.setNoise(v);
              engine.refreshNoise();
            },
          ),
          if (settings.noiseOn) ...[
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: AmbientSound.values.map((s) {
                  final selected = settings.soundType == s;
                  final labels = _soundLabels[s]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: selected,
                      avatar: Icon(
                        _soundIcons[s],
                        size: 18,
                        color: selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                      label: Text(
                        labels.$1,
                        style: TextStyle(
                          color: selected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurface,
                        ),
                      ),
                      onSelected: (_) {
                        settings.setSoundType(s);
                        NoisePlayer.instance.setSound(s);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.volume_up, size: 18),
                  Expanded(
                    child: Slider(
                      value: settings.noiseVolume,
                      min: 0,
                      max: 1,
                      onChanged: (v) {
                        settings.setVolume(v);
                        NoisePlayer.instance.setVolume(v);
                      },
                    ),
                  ),
                  const Icon(Icons.graphic_eq, size: 18),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
            child: Column(
              children: [
                Text(
                  '${tr('今日', 'Today')} '
                  '${stats.todaySessions()}/${settings.dailyGoalSessions} '
                  '${tr('个番茄', 'pomodoros')}',
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (stats.todaySessions() / settings.dailyGoalSessions)
                      .clamp(0.0, 1.0)
                      .toDouble(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
