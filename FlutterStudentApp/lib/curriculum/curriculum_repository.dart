import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/curriculum_models.dart';

class CurriculumRepository {
  Future<List<CurriculumUnit>> loadLevel(
    CurriculumLevel level,
  ) async {
    final raw = await rootBundle.loadString(
      'assets/content/curriculum_${level.id}.json',
    );
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final units = (decoded['units'] as List<dynamic>)
        .map((item) => CurriculumUnit.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
    units.sort((a, b) => a.order.compareTo(b.order));
    return units;
  }
  Future<List<CurriculumUnit>> loadAll() async {
    final result = <CurriculumUnit>[];
    for (final level in CurriculumLevel.values) {
      result.addAll(await loadLevel(level));
    }
    return result;
  }
}
