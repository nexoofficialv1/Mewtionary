import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../services/dictionary_pack_service.dart';

class DictionaryPackManagerScreen extends StatefulWidget {
  const DictionaryPackManagerScreen({
    required this.service,
    super.key,
  });

  final DictionaryPackService service;

  @override
  State<DictionaryPackManagerScreen> createState() =>
      _DictionaryPackManagerScreenState();
}

class _DictionaryPackManagerScreenState
    extends State<DictionaryPackManagerScreen> {
  int count = 0;
  List<Map<String, Object?>> installed = const [];
  bool busy = false;
  String status = 'Data-pack engine প্রস্তুত।';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final nextCount = await widget.service.installedEntryCount();
    final packs = await widget.service.installedPacks();
    if (!mounted) return;
    setState(() {
      count = nextCount;
      installed = packs;
    });
  }

  Future<void> _starter() async {
    setState(() {
      busy = true;
      status = 'Starter pack install হচ্ছে…';
    });
    try {
      final result = await widget.service.installBundledPack();
      status =
          '${result.imported} entries processed; ${result.skipped} skipped.';
      await _refresh();
    } catch (error) {
      status = 'Install failed: $error';
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _external() async {
    const manifestTypes = XTypeGroup(
      label: 'Mewtionary manifest',
      extensions: ['json'],
      mimeTypes: ['application/json'],
    );
    const dataTypes = XTypeGroup(
      label: 'Mewtionary dictionary entries',
      extensions: ['jsonl', 'txt'],
      mimeTypes: ['application/json', 'text/plain'],
    );

    final manifest = await openFile(
      acceptedTypeGroups: const [manifestTypes],
    );
    if (manifest == null) return;

    final data = await openFile(
      acceptedTypeGroups: const [dataTypes],
    );
    if (data == null) return;

    setState(() {
      busy = true;
      status = 'Pack যাচাই ও import হচ্ছে…';
    });
    try {
      final manifestBytes = await manifest.readAsBytes();
      final dataBytes = await data.readAsBytes();
      final result = await widget.service.installBytes(
        manifestJson: utf8.decode(manifestBytes),
        jsonlBytes: Uint8List.fromList(dataBytes),
      );
      status = '${result.packId}: ${result.imported} entries processed.';
      await _refresh();
    } catch (error) {
      status = 'Pack rejected: $error';
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dictionary Data Packs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFFFF1C7),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.storage_rounded,
                    size: 58,
                    color: MewtionaryTheme.teal,
                  ),
                  Text(
                    '$count offline entries',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: MewtionaryTheme.navy,
                              fontWeight: FontWeight.w900,
                            ),
                  ),
                  const Text(
                    'Licensed pack যোগ করলে একই engine বড় dataset ব্যবহার করবে।',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: busy ? null : _starter,
            icon: const Icon(Icons.download_done_rounded),
            label: const Text('Install Bundled Starter Pack'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: busy ? null : _external,
            icon: const Icon(Icons.file_open_rounded),
            label: const Text('Import Licensed JSONL Pack'),
          ),
          if (busy) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                status,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          for (final pack in installed)
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.inventory_2_rounded),
                ),
                title: Text(
                  pack['name'] as String? ?? 'Dictionary Pack',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '${pack['entry_count']} entries · '
                  '${pack['license']} · v${pack['version']}',
                ),
              ),
            ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(17),
              child: Text(
                'পূর্ণ ১,০০,০০০ শব্দের dataset এখানে দাবি করা হয়নি। '
                'Original, licensed অথবা public-domain data ব্যবহার করতে হবে।',
                style: TextStyle(color: Colors.black54, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
