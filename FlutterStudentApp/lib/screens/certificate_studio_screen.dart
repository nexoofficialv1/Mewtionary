import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../models/exam_coach_models.dart';
import '../services/certificate_service.dart';

class CertificateStudioScreen extends StatefulWidget {
  const CertificateStudioScreen({
    required this.service,
    super.key,
  });

  final CertificateService service;

  @override
  State<CertificateStudioScreen> createState() =>
      _CertificateStudioScreenState();
}

class _CertificateStudioScreenState
    extends State<CertificateStudioScreen> {
  List<CertificateStatus> certificates = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.service.load();
    if (!mounted) return;
    setState(() {
      certificates = data;
      loading = false;
    });
  }

  Future<void> _export(CertificateDefinition definition) async {
    final path = await widget.service.export(definition);
    if (!mounted || path == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Certificate saved: $path')),
    );
  }

  Future<void> _preview(CertificateStatus status) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status.definition.icon,
                style: const TextStyle(fontSize: 58),
              ),
              Text(
                status.definition.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  color: MewtionaryTheme.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                status.definition.banglaTitle,
                textAlign: TextAlign.center,
              ),
              const Divider(height: 28),
              Text(
                status.definition.description,
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.4),
              ),
              const SizedBox(height: 16),
              if (status.unlocked)
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _export(status.definition);
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Export Printable Certificate'),
                )
              else
                Text(
                  'Progress ${(status.progress * 100).round()}%',
                  style: const TextStyle(
                    color: MewtionaryTheme.teal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = certificates
        .where((item) => item.unlocked)
        .length;
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate Studio')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFFFFF1C7),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 65,
                            color: MewtionaryTheme.amber,
                          ),
                          const Text(
                            'Learning Certificates',
                            style: TextStyle(
                              fontSize: 24,
                              color: MewtionaryTheme.navy,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '$unlocked/${certificates.length} unlocked',
                          ),
                        ],
                      ),
                    ),
                  ),
                  for (final status in certificates)
                    Card(
                      color: status.unlocked
                          ? const Color(0xFFDFF4E2)
                          : Colors.white,
                      child: ListTile(
                        onTap: () => _preview(status),
                        leading: CircleAvatar(
                          backgroundColor: status.unlocked
                              ? MewtionaryTheme.amber.withValues(alpha: .22)
                              : Colors.grey.shade200,
                          child: Text(
                            status.unlocked
                                ? status.definition.icon
                                : '🔒',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        title: Text(
                          status.definition.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: status.unlocked
                                ? MewtionaryTheme.navy
                                : Colors.grey,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(status.definition.banglaTitle),
                            Text(status.definition.description),
                            const SizedBox(height: 7),
                            LinearProgressIndicator(
                              value: status.progress,
                              minHeight: 7,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: status.unlocked
                            ? const Icon(
                                Icons.download_rounded,
                                color: Colors.green,
                              )
                            : Text(
                                '${(status.progress * 100).round()}%',
                              ),
                      ),
                    ),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Certificates locally generated achievement documents। '
                        'এগুলো কোনো school board বা সরকারি academic certificate নয়।',
                        style: TextStyle(
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
