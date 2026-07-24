import 'package:flutter_test/flutter_test.dart';
import 'package:mewtionary_student/models/tutor_studio_models.dart';
import 'package:mewtionary_student/services/homework_studio_service.dart';

void main() {
  final service = HomeworkStudioService();

  const template = HomeworkTemplate(
    id: 'paragraph',
    levelId: 'class_4',
    type: HomeworkType.paragraph,
    title: 'Paragraph',
    banglaTitle: 'অনুচ্ছেদ',
    instructions: '',
    fields: [
      HomeworkFieldDefinition(
        key: 'opening',
        label: 'Opening',
        hint: '',
        required: true,
        multiline: false,
      ),
      HomeworkFieldDefinition(
        key: 'details',
        label: 'Details',
        hint: '',
        required: true,
        multiline: true,
      ),
    ],
    outputTemplate: '{{opening}} {{details}}',
    checklist: [],
  );

  test('generates text from template fields', () {
    final output = service.generate(
      template,
      {
        'opening': 'My school is beautiful.',
        'details': 'It has a large playground.',
      },
    );
    expect(output, contains('large playground'));
  });

  test('flags missing fields', () {
    final output = service.generate(
      template,
      {'opening': 'My school is beautiful.'},
    );
    final review = service.review(
      template: template,
      values: {'opening': 'My school is beautiful.'},
      output: output,
    );
    expect(review.score, lessThan(100));
    expect(review.messages.first, contains('Details'));
  });
}
