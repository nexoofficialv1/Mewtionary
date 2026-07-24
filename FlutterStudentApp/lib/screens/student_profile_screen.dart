import 'package:flutter/material.dart';

import '../models/curriculum_models.dart';
import '../services/student_profile_service.dart';
import '../services/teacher_orchestrator.dart';
import '../widgets/teacher_viewport.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({
    required this.service,
    required this.teacher,
    super.key,
  });

  final StudentProfileService service;
  final TeacherOrchestrator teacher;

  @override
  State<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late final TextEditingController nameController;
  late int age;
  late CurriculumLevel level;

  @override
  void initState() {
    super.initState();
    final profile = widget.service.profile;
    nameController = TextEditingController(text: profile.name);
    age = profile.age;
    level = profile.level;
  }

  Future<void> _save() async {
    await widget.service.save(
      name: nameController.text,
      age: age,
      level: level,
    );
    await widget.teacher.praise(
      '${widget.service.profile.name}, তোমার profile save হয়েছে।',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student profile saved')),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TeacherViewport(teacher: widget.teacher, height: 260),
          const SizedBox(height: 14),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Student name',
              prefixIcon: Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: age,
            decoration: const InputDecoration(
              labelText: 'Age',
              prefixIcon: Icon(Icons.cake_rounded),
            ),
            items: [
              for (var value = 4; value <= 16; value++)
                DropdownMenuItem(
                  value: value,
                  child: Text('$value years'),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => age = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CurriculumLevel>(
            value: level,
            decoration: const InputDecoration(
              labelText: 'Current learning level',
              prefixIcon: Icon(Icons.school_rounded),
            ),
            items: CurriculumLevel.values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      '${item.title} — ${item.banglaTitle}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => level = value);
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }
}
