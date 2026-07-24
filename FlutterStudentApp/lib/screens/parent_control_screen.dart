import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../services/parent_control_service.dart';

class ParentControlScreen extends StatelessWidget {
  const ParentControlScreen({
    required this.service,
    super.key,
  });

  final ParentControlService service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Controls')),
      body: AnimatedBuilder(
        animation: service,
        builder: (context, _) {
          final state = service.state;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                color: Color(0xFFFFF1C7),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: MewtionaryTheme.amber,
                    child: Icon(
                      Icons.family_restroom_rounded,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'শিশুর learning settings',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    'সময়, voice, বাংলা সহায়তা ও animation নিয়ন্ত্রণ করুন।',
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Daily learning: ${state.dailyMinutes} minutes',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Slider(
                        value: state.dailyMinutes.toDouble(),
                        min: 10,
                        max: 120,
                        divisions: 11,
                        label: '${state.dailyMinutes} min',
                        onChanged: (value) {
                          service.setDailyMinutes(value.round());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: state.voiceEnabled,
                      onChanged: service.setVoiceEnabled,
                      title: const Text(
                        'Voice interaction',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    SwitchListTile(
                      value: state.banglaSupport,
                      onChanged: service.setBanglaSupport,
                      title: const Text(
                        'Bangla support text',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    SwitchListTile(
                      value: state.lowMotion,
                      onChanged: service.setLowMotion,
                      title: const Text(
                        'Low-motion mode',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'Dance, bounce ও idle motion কমাবে',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
