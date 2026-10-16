import 'package:app/theme/emotion_visuals.dart';
import 'package:flutter/material.dart';

class EmotionDialog extends StatelessWidget {
  const EmotionDialog({
    super.key,
    required this.sensorEmotion,
    this.cameraEmotion,
    required this.onClosed,
  });

  final String sensorEmotion;
  final String? cameraEmotion;
  final void Function() onClosed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasCamera = cameraEmotion != null && cameraEmotion!.trim().isNotEmpty;
    final match = hasCamera &&
        cameraEmotion!.trim().toLowerCase() ==
            sensorEmotion.trim().toLowerCase();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan Result',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            if (hasCamera) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Source(label: 'Camera', emotion: cameraEmotion),
                  _Source(label: 'Sensor', emotion: sensorEmotion),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: (match ? scheme.primary : scheme.tertiary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  match
                      ? 'Both agree on this emotion.'
                      : 'The camera and sensor disagreed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: match ? scheme.primary : scheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              _Source(label: 'Sensor', emotion: sensorEmotion),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onClosed,
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Source extends StatelessWidget {
  const _Source({required this.label, required this.emotion});
  final String label;
  final String? emotion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = emotionVisual(emotion);
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        CircleAvatar(
          radius: 30,
          backgroundColor: v.color.withValues(alpha: 0.16),
          foregroundColor: v.color,
          child: Icon(v.icon, size: 34),
        ),
        const SizedBox(height: 8),
        Text(
          v.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
