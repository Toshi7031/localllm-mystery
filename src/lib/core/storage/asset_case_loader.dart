import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/case_data.dart';

class AssetCaseLoader {
  Future<CaseData> loadCase(String caseId) async {
    final String jsonString = await rootBundle.loadString('assets/cases/$caseId/$caseId.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return CaseData.fromJson(jsonMap);
  }
}
