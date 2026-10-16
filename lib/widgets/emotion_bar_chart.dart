import 'package:app/theme/emotion_visuals.dart';
import 'package:flutter/material.dart';

/// Vertical bars, one per emotion, for the face model's scores. Fills the
/// height it is given; the top emotion is emphasised.
class EmotionBarChart extends StatelessWidget {
  const EmotionBarChart({super.key, required this.scores});

  /// Emotion label -> probability (0..1), in display order.
  final Map<String, double> scores;

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const SizedBox.shrink();
    final top = scores.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final e in scores.entries)
          Expanded(
            child: _EmotionBar(
              emotion: e.key,
              value: e.value.clamp(0.0, 1.0),
              isTop: e.key == top,
            ),
          ),
      ],
    );
  }
}

class _EmotionBar extends StatelessWidget {
  const _EmotionBar({
    required this.emotion,
    required this.value,
    required this.isTop,
  });

  final String emotion;
  final double value;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    final v = emotionVisual(emotion);
    final scheme = Theme.of(context).colorScheme;
    final weight = isTop ? FontWeight.w700 : FontWeight.w500;
    return Column(
      children: [
        // softmax probabilities are 0..1 -> percent.
        Text(
          '${(value * 100).round()}%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: weight,
            color: isTop ? v.color : scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Container(
              width: 36,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: v.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              // Animated so the bars glide between camera frames.
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: double.infinity,
                height: constraints.maxHeight * value,
                decoration: BoxDecoration(
                  color: isTop ? v.color : v.color.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Icon(v.icon, color: v.color, size: 20),
        const SizedBox(height: 2),
        Text(
          v.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: weight),
        ),
      ],
    );
  }
}
