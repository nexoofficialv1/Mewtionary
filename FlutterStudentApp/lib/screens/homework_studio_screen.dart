import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../models/tutor_studio_models.dart';
import '../services/homework_studio_service.dart';
import '../services/student_profile_service.dart';
import '../services/learning_feedback_service.dart';
import '../services/tutor_studio_content_service.dart';
import '../widgets/learning_feedback_anchor.dart';

class HomeworkStudioScreen extends StatefulWidget {
  const HomeworkStudioScreen({
    required this.content,
    required this.studio,
    required this.profile,
    required this.teacher,
    super.key,
  });

  final TutorStudioContentService content;
  final HomeworkStudioService studio;
  final StudentProfileService profile;
  final LearningFeedbackService teacher;

  @override
  State<HomeworkStudioScreen> createState() =>
      _HomeworkStudioScreenState();
}

class _HomeworkStudioScreenState
    extends State<HomeworkStudioScreen> {
  List<HomeworkTemplate> templates = const [];
  HomeworkTemplate? selected;
  final controllers = <String, TextEditingController>{};
  String preview = '';
  HomeworkReview? review;
  int? draftId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.profile.load();
    final data = await widget.content.loadHomeworkTemplates(
      widget.profile.profile.level,
    );
    if (!mounted) return;
    setState(() {
      templates = data;
      loading = false;
    });
    if (data.isNotEmpty) _select(data.first);
  }

  void _select(HomeworkTemplate template) {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
    for (final field in template.fields) {
      controllers[field.key] = TextEditingController();
    }
    setState(() {
      selected = template;
      preview = '';
      review = null;
      draftId = null;
    });
    widget.teacher.act(
      state: LearningFeedbackState.writingBoard,
      message: template.instructions,
      prop: LearningFeedbackContext.chalk,
    );
  }

  Map<String, String> _values() => {
        for (final entry in controllers.entries)
          entry.key: entry.value.text,
      };

  Future<void> _generateAndReview() async {
    final template = selected;
    if (template == null) return;
    final output = widget.studio.generate(
      template,
      _values(),
    );
    final result = widget.studio.review(
      template: template,
      values: _values(),
      output: output,
    );
    if (!mounted) return;
    setState(() {
      preview = output;
      review = result;
    });

    if (result.score >= 80) {
      await widget.teacher.praise(
        'Draft score ${result.score} percent. Structure ভালো হয়েছে।',
      );
    } else {
      await widget.teacher.correct(result.messages.first);
    }
  }

  Future<void> _save() async {
    final template = selected;
    if (template == null || preview.isEmpty) return;
    final id = await widget.studio.saveDraft(
      id: draftId,
      template: template,
      title: template.title,
      content: preview,
    );
    if (!mounted) return;
    setState(() => draftId = id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Homework draft saved offline')),
    );
  }

  Future<void> _copy() async {
    if (preview.isEmpty) return;
    await widget.studio.copyToClipboard(preview);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft copied')),
    );
  }

  Future<void> _export() async {
    final template = selected;
    if (template == null || preview.isEmpty) return;
    final path = await widget.studio.exportText(
      title: template.title,
      content: preview,
    );
    if (!mounted || path == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved: $path')),
    );
  }

  Future<void> _showDrafts() async {
    final drafts = await widget.studio.loadDrafts();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .7,
          child: drafts.isEmpty
              ? const Center(child: Text('No saved drafts'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Saved Homework Drafts',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    for (final draft in drafts)
                      Card(
                        child: ListTile(
                          title: Text(draft.title),
                          subtitle: Text(
                            draft.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            setState(() {
                              draftId = draft.id;
                              preview = draft.content;
                              review = null;
                            });
                          },
                          trailing: IconButton(
                            onPressed: () async {
                              if (draft.id != null) {
                                await widget.studio
                                    .deleteDraft(draft.id!);
                              }
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                              _showDrafts();
                            },
                            icon: const Icon(Icons.delete_rounded),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final template = selected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Studio'),
        actions: [
          IconButton(
            onPressed: _showDrafts,
            icon: const Icon(Icons.folder_rounded),
          ),
        ],
      ),
      body: loading || template == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LearningFeedbackAnchor(
                  teacher: widget.teacher,
                  height: 245,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<HomeworkTemplate>(
                  value: template,
                  decoration: const InputDecoration(
                    labelText: 'Homework format',
                    prefixIcon: Icon(Icons.assignment_rounded),
                  ),
                  items: templates
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            '${item.type.title}: ${item.title}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) _select(value);
                  },
                ),
                const SizedBox(height: 12),
                Card(
                  color: const Color(0xFFFFF1C7),
                  child: ListTile(
                    title: Text(
                      template.banglaTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(template.instructions),
                  ),
                ),
                for (final field in template.fields)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: TextField(
                      controller: controllers[field.key],
                      minLines: field.multiline ? 3 : 1,
                      maxLines: field.multiline ? 7 : 1,
                      decoration: InputDecoration(
                        labelText: field.label,
                        hintText: field.hint,
                        suffixText: field.required ? 'Required' : null,
                      ),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: _generateAndReview,
                  icon: const Icon(Icons.auto_fix_high_rounded),
                  label: const Text('Build & Review Draft'),
                ),
                if (preview.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Draft Preview',
                            style: TextStyle(
                              color: MewtionaryTheme.teal,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SelectableText(
                            preview,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (review != null)
                    Card(
                      color: review!.score >= 80
                          ? const Color(0xFFDFF4E2)
                          : const Color(0xFFFFE8D9),
                      child: Padding(
                        padding: const EdgeInsets.all(17),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Writing Review: ${review!.score}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            for (final message in review!.messages)
                              Text('• $message'),
                            const SizedBox(height: 10),
                            const Text(
                              'Checklist',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            for (final item in template.checklist)
                              Text('✓ $item'),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copy,
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('Copy'),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Save'),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _export,
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Export'),
                        ),
                      ),
                    ],
                  ),
                ],
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Homework Studio structure, checklist ও basic writing '
                      'rules দিয়ে feedback দেয়। এটি শিক্ষার্থীর হয়ে সম্পূর্ণ '
                      'homework লিখে দেওয়া open-ended AI নয়।',
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
