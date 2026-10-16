import 'package:flutter/material.dart';

/// A consistent icon + color + label for each emotion, so history, detail and
/// the result dialog all present emotions the same way.
class EmotionVisual {
  final IconData icon;
  final Color color;
  final String label;
  const EmotionVisual(this.icon, this.color, this.label);
}

EmotionVisual emotionVisual(String? emotion) {
  switch (emotion?.trim().toLowerCase()) {
    case 'happy':
      return const EmotionVisual(
          Icons.sentiment_very_satisfied, Color(0xFFF59E0B), 'Happy');
    case 'relaxed':
      return const EmotionVisual(
          Icons.sentiment_satisfied, Color(0xFF10B981), 'Relaxed');
    case 'neutral':
      return const EmotionVisual(
          Icons.sentiment_neutral, Color(0xFF64748B), 'Neutral');
    case 'sad':
      return const EmotionVisual(
          Icons.sentiment_dissatisfied, Color(0xFF3B82F6), 'Sad');
    case 'fear':
      return const EmotionVisual(Icons.mood_bad, Color(0xFF8B5CF6), 'Fear');
    case 'angry':
      return const EmotionVisual(
          Icons.sentiment_very_dissatisfied, Color(0xFFEF4444), 'Angry');
    default:
      final text = (emotion == null || emotion.trim().isEmpty)
          ? 'Unknown'
          : emotion.trim();
      return EmotionVisual(Icons.help_outline, const Color(0xFF94A3B8), text);
  }
}

/// A compact pill showing the emotion's icon and label. Reused across screens.
class EmotionChip extends StatelessWidget {
  const EmotionChip({super.key, required this.emotion, this.large = false});

  final String? emotion;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final v = emotionVisual(emotion);
    final double iconSize = large ? 22 : 18;
    final double fontSize = large ? 16 : 14;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: v.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(v.icon, color: v.color, size: iconSize),
          const SizedBox(width: 8),
          // Flexible so a long label ("Not recorded") wraps instead of
          // overflowing when the chip sits in a narrow column.
          Flexible(
            child: Text(
              v.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: v.color,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
