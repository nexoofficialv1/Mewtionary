import 'package:flutter/material.dart';

import '../services/learning_feedback_service.dart';

/// Kept temporarily so existing screens do not require risky layout rewrites.
/// It intentionally renders nothing: Mewtionary v2.8 has no visual guide.
class LearningFeedbackAnchor extends StatelessWidget {
  const LearningFeedbackAnchor({
    required this.teacher,
    this.height = 0,
    super.key,
  });

  final LearningFeedbackService teacher;
  final double height;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
