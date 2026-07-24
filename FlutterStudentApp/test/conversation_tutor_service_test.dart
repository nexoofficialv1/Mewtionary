import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/tutor_studio_models.dart';
import 'package:mewtionary_student/services/conversation_tutor_service.dart';

void main() {
  final service = ConversationTutorService();

  const node = ConversationNode(
    id: 'hello',
    speaker: 'Partner',
    prompt: 'What is your name?',
    banglaPrompt: '',
    teacherHint: '',
    isFinal: false,
    replies: [
      ConversationReply(
        id: 'name',
        text: 'My name is Riya.',
        expectedKeywords: ['my', 'name', 'is'],
        teacherReply: 'Nice to meet you.',
        nextNodeId: null,
        score: 12,
      ),
    ],
  );

  test('accepts a reply with keyword coverage', () {
    final result = service.evaluate(
      node: node,
      answer: 'My name is Riya',
    );
    expect(result.accepted, isTrue);
    expect(result.score, 12);
  });

  test('returns missing keywords for an incomplete reply', () {
    final result = service.evaluate(
      node: node,
      answer: 'Riya',
    );
    expect(result.accepted, isFalse);
    expect(result.missingKeywords, contains('name'));
  });
}
