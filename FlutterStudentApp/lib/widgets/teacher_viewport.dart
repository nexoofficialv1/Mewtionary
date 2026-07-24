import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../services/teacher_orchestrator.dart';

class TeacherViewport extends StatelessWidget {
  const TeacherViewport({
    required this.teacher,
    this.height = 310,
    super.key,
  });

  final TeacherOrchestrator teacher;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: teacher,
      builder: (context, _) {
        final status = teacher.status;
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (status.unityAvailable &&
                    !kIsWeb &&
                    defaultTargetPlatform == TargetPlatform.android)
                  const AndroidView(
                    viewType: 'mewtionary/teacher3d_view',
                  )
                else
                  const _UnityFallbackStage(),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: _SpeechBubble(
                    message: status.message,
                    state: status.state.name,
                    connected: status.unityAvailable,
                    speaking: status.speaking,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UnityFallbackStage extends StatelessWidget {
  const _UnityFallbackStage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFBEE4EA),
            Color(0xFFEAF6E6),
            Color(0xFFFFE9B8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 22,
            top: 24,
            child: Container(
              width: 160,
              height: 104,
              decoration: BoxDecoration(
                color: const Color(0xFF174E43),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF9A6B39),
                  width: 6,
                ),
              ),
              child: const Center(
                child: Text(
                  'A B C\nঅ আ ক খ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            right: 26,
            top: 42,
            child: Icon(
              Icons.view_in_ar_rounded,
              size: 92,
              color: MewtionaryTheme.navy,
            ),
          ),
          Positioned(
            right: 22,
            top: 142,
            child: Container(
              width: 174,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .84),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Unity 3D Teacher viewport\nFinal model যুক্ত হলে এখানে live Teacher দেখা যাবে।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MewtionaryTheme.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.message,
    required this.state,
    required this.connected,
    required this.speaking,
  });

  final String message;
  final String state;
  final bool connected;
  final bool speaking;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: connected
                  ? MewtionaryTheme.teal
                  : MewtionaryTheme.amber,
              child: Icon(
                speaking ? Icons.graphic_eq : Icons.school_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: MewtionaryTheme.teal,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: connected
                  ? 'Unity connected'
                  : 'Safe fallback mode',
              child: Icon(
                connected ? Icons.link_rounded : Icons.link_off_rounded,
                color: connected
                    ? MewtionaryTheme.teal
                    : Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
