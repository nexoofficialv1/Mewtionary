import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../data/content_repository.dart';
import '../models/learning_models.dart';
import '../services/progress_service.dart';
import '../services/teacher_orchestrator.dart';
import '../widgets/teacher_viewport.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({
    required this.teacher,
    required this.progress,
    required this.repository,
    super.key,
  });

  final TeacherOrchestrator teacher;
  final ProgressService progress;
  final ContentRepository repository;

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final queryController = TextEditingController();
  List<DictionaryEntry> all = const [];
  List<DictionaryEntry> results = const [];
  DictionaryEntry? selected;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await widget.repository.loadDictionary();
    if (!mounted) return;
    setState(() {
      all = entries;
      results = entries;
      selected = entries.firstOrNull;
      loading = false;
    });
  }

  void _search(String value) {
    setState(() {
      results = widget.repository.searchDictionary(all, value);
      if (results.isNotEmpty) selected = results.first;
    });
  }

  Future<void> _explain(DictionaryEntry entry) async {
    setState(() => selected = entry);
    await widget.teacher.explainDictionary(
      word: entry.word,
      meaning: entry.bangla,
      example: entry.example,
    );
    await widget.progress.addDictionaryWord();
  }

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dictionary')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TeacherViewport(
                  teacher: widget.teacher,
                  height: 285,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: queryController,
                  onChanged: _search,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'English অথবা বাংলা শব্দ লিখুন',
                    suffixIcon: Icon(Icons.mic_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                if (selected != null)
                  _EntryDetails(
                    entry: selected!,
                    onExplain: () => _explain(selected!),
                  ),
                const SizedBox(height: 12),
                Text(
                  '${results.length} results',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: MewtionaryTheme.teal,
                      ),
                ),
                const SizedBox(height: 6),
                ...results.map(
                  (entry) => Card(
                    child: ListTile(
                      onTap: () => _explain(entry),
                      leading: CircleAvatar(
                        backgroundColor:
                            MewtionaryTheme.teal.withValues(alpha: .12),
                        child: Text(
                          entry.word.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: MewtionaryTheme.teal,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      title: Text(
                        entry.word,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        '${entry.bangla} · ${entry.partOfSpeech}',
                      ),
                      trailing: IconButton(
                        onPressed: () => _explain(entry),
                        icon: const Icon(Icons.volume_up_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EntryDetails extends StatelessWidget {
  const _EntryDetails({
    required this.entry,
    required this.onExplain,
  });

  final DictionaryEntry entry;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFCF4),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.word,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: MewtionaryTheme.navy,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onExplain,
                  icon: const Icon(Icons.school_rounded),
                  label: const Text('Teacher'),
                ),
              ],
            ),
            Text(
              '${entry.pronunciation} · ${entry.partOfSpeech}',
              style: const TextStyle(color: Colors.black54),
            ),
            const Divider(height: 24),
            Text(
              entry.bangla,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(entry.definition),
            const SizedBox(height: 12),
            Text(
              entry.example,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              entry.exampleBangla,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
