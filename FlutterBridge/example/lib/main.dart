import 'package:flutter/material.dart';
import 'package:mewtionary_teacher3d_bridge/mewtionary_teacher3d_bridge.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const TeacherLessonDemo(),
    );
  }
}

class TeacherLessonDemo extends StatefulWidget {
  const TeacherLessonDemo({super.key});

  @override
  State<TeacherLessonDemo> createState() => _TeacherLessonDemoState();
}

class _TeacherLessonDemoState extends State<TeacherLessonDemo> {
  final lesson = Teacher3DLessonController();
  bool? available;

  @override
  void initState() {
    super.initState();
    lesson.bridge.isUnityAvailable.then((value) {
      if (mounted) setState(() => available = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mewtionary 3D Teacher v2.1')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                available == true ? Icons.check_circle : Icons.info_outline,
              ),
              title: Text(
                available == true
                    ? 'Unity Teacher connected'
                    : 'Unity library is not embedded yet',
              ),
              subtitle: const Text(
                'This host screen sends lesson commands to the Unity character.',
              ),
            ),
          ),
          FilledButton(
            onPressed: () => lesson.welcome('বন্ধু'),
            child: const Text('Welcome'),
          ),
          FilledButton.tonal(
            onPressed: () => lesson.explainDictionaryWord(
              word: 'Beautiful',
              meaning: 'সুন্দর',
              example: 'The flower is beautiful.',
            ),
            child: const Text('Dictionary Demo'),
          ),
          FilledButton.tonal(
            onPressed: lesson.teachPresentTense,
            child: const Text('Tense Demo'),
          ),
          FilledButton.tonal(
            onPressed: () => lesson.startStory(
              'Once there was an honest woodcutter.',
            ),
            child: const Text('Story Demo'),
          ),
          FilledButton.tonal(
            onPressed: lesson.listenToChild,
            child: const Text('Listen'),
          ),
          FilledButton.tonal(
            onPressed: lesson.praise,
            child: const Text('Praise'),
          ),
          FilledButton.tonal(
            onPressed: () => lesson.correctGently(
              'He-এর সঙ্গে goes হবে।',
            ),
            child: const Text('Gentle Correction'),
          ),
          FilledButton.tonal(
            onPressed: lesson.celebrate,
            child: const Text('Celebrate'),
          ),
        ],
      ),
    );
  }
}
