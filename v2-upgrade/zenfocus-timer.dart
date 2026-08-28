import 'package:flutter/material.dart';
import 'package:zenfocus/core/theme/app_theme.dart';

class TimerCard extends StatefulWidget {
  final Animation<double> animation;

  const TimerCard({super.key, required this.animation});

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  int minutes = 25;
  int seconds = 0;
  bool isRunning = false;
  String selectedTimerType = '专注';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animation.value,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildTimerTypeSelector(),
                  const SizedBox(height: 24),
                  _buildTimerDisplay(),
                  const SizedBox(height: 32),
                  _buildProgressIndicator(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTypeButton('专注', AppTheme.primaryColor),
        const SizedBox(width: 12),
        _buildTypeButton('短休', AppTheme.successColor),
        const SizedBox(width: 12),
        _buildTypeButton('长休', AppTheme.warningColor),
      ],
    );
  }

  Widget _buildTypeButton(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selectedTimerType == type ? color : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: selectedTimerType == type ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Column(
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          selectedTimerType == '专注' ? '专注时间' : '休息时间',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    double progress = minutes > 0 ? (minutes * 60 - seconds) / (minutes * 60) : 0;
    
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}