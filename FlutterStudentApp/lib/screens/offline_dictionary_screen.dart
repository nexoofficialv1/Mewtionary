import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../services/dictionary_pack_service.dart';
import '../services/progress_service.dart';
import '../services/teacher_orchestrator.dart';
import '../widgets/teacher_viewport.dart';

class OfflineDictionaryScreen extends StatefulWidget {
  const OfflineDictionaryScreen({
    required this.teacher,
    required this.progress,
    required this.service,
    super.key,
  });

  final TeacherOrchestrator teacher;
  final ProgressService progress;
  final DictionaryPackService service;

  @override
  State<OfflineDictionaryScreen> createState() =>
      _OfflineDictionaryScreenState();
}

class _OfflineDictionaryScreenState
    extends State<OfflineDictionaryScreen> {
  final controller = TextEditingController();
  List<Map<String, Object?>> results = const [];
  Map<String, Object?>? selected;
  bool loading = true;
  String status = 'Offline dictionary প্রস্তুত হচ্ছে…';

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final count = await widget.service.installedEntryCount();
      if (count == 0) {
        await widget.service.installBundledPack();
      }
      final data = await widget.service.search('');
      if (!mounted) return;
      setState(() {
        results = data;
        selected = data.isEmpty ? null : data.first;
        loading = false;
        status = '${data.length}টি entry দেখানো হচ্ছে।';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loading = false;
        status = 'Dictionary load failed: $error';
      });
    }
  }

  Future<void> _search(String query) async {
    final data = await widget.service.search(query);
    if (!mounted) return;
    setState(() {
      results = data;
      selected = data.isEmpty ? null : data.first;
      status = '${data.length} results';
    });
  }

  Future<void> _explain(Map<String, Object?> entry) async {
    setState(() => selected = entry);
    await widget.teacher.explainDictionary(
      word: entry['word'] as String? ?? '',
      meaning: entry['bangla'] as String? ?? '',
      example: entry['example'] as String? ?? '',
    );
    await widget.progress.addDictionaryWord();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Dictionary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TeacherViewport(teacher: widget.teacher, height: 280),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            onChanged: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'English অথবা বাংলা শব্দ লিখুন',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            status,
            style: const TextStyle(
              color: MewtionaryTheme.teal,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (selected != null)
            Card(
              color: const Color(0xFFFFFCF3),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected!['word'] as String? ?? '',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: MewtionaryTheme.navy,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    Text(
                      '${selected!['bangla']} · '
                      '${selected!['part_of_speech']}',
                      style: const TextStyle(
                        color: MewtionaryTheme.teal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      selected!['definition'] as String? ?? '',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selected!['example'] as String? ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      selected!['example_bangla'] as String? ?? '',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _explain(selected!),
                      icon: const Icon(Icons.school_rounded),
                      label: const Text('Teacher বুঝিয়ে দাও'),
                    ),
                  ],
                ),
              ),
            ),
          for (final entry in results)
            Card(
              child: ListTile(
                onTap: () => _explain(entry),
                title: Text(
                  entry['word'] as String? ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '${entry['bangla']} · ${entry['part_of_speech']}',
                ),
                trailing: const Icon(Icons.volume_up_rounded),
              ),
            ),
        ],
      ),
    );
  }
}
