import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../services/settings_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      icon: Icons.timer,
      titleZh: '专注，从此刻开始',
      titleEn: 'Focus starts now',
      descZh: '使用番茄工作法，将时间拆分为高效专注段，配合短暂休息，让每一分钟都有价值。',
      descEn: 'Use the Pomodoro Technique to break time into focused sessions with short breaks.',
    ),
    _OnboardPage(
      icon: Icons.music_note,
      titleZh: '沉浸式环境',
      titleEn: 'Immersive environment',
      descZh: '内置 5 种环境音效 — 棕噪、白噪、雨声、森林、深潜，帮助你快速进入心流状态。',
      descEn: '5 built-in ambient sounds to help you enter a flow state quickly.',
    ),
    _OnboardPage(
      icon: Icons.insights,
      titleZh: '数据驱动成长',
      titleEn: 'Data-driven growth',
      descZh: '详细的专注统计、连续天数追踪、成就系统，用数据见证你的每一步进步。',
      descEn: 'Detailed stats, streak tracking, and achievements to witness your progress.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(tr('跳过', 'Skip')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: FilledButton(
                onPressed: () {
                  if (_page < _pages.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finish();
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  _page < _pages.length - 1
                      ? tr('下一步', 'Next')
                      : tr('开始使用', 'Get started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finish() {
    context.read<SettingsProvider>().completeOnboarding();
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.icon,
    required this.titleZh,
    required this.titleEn,
    required this.descZh,
    required this.descEn,
  });

  final IconData icon;
  final String titleZh, titleEn, descZh, descEn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 40),
          Text(
            tr(titleZh, titleEn),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            tr(descZh, descEn),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
