import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stores user-generated exports without requesting broad storage access.
///
/// Android and supported desktop platforms use the Downloads directory
/// when available. A private application documents directory is used as
/// a safe fallback.
class AppFileService {
  const AppFileService._();

  static Future<String> saveText({
    required String fileName,
    required String content,
  }) {
    return saveBytes(
      fileName: fileName,
      bytes: utf8.encode(content),
    );
  }

  static Future<String> saveBytes({
    required String fileName,
    required List<int> bytes,
  }) async {
    final downloads = await getDownloadsDirectory();
    final base = downloads ?? await getApplicationDocumentsDirectory();
    final exportDirectory = Directory(
      p.join(base.path, 'Mewtionary'),
    );
    await exportDirectory.create(recursive: true);

    final safeName = _safeFileName(fileName);
    final output = File(p.join(exportDirectory.path, safeName));
    await output.writeAsBytes(bytes, flush: true);
    return output.path;
  }

  static String _safeFileName(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();

    if (cleaned.isEmpty || cleaned == '.' || cleaned == '..') {
      return 'mewtionary_export.txt';
    }
    return cleaned;
  }
}
