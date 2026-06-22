import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'installed_model_info.dart';
import 'model_manifest.dart';
import 'model_download_service.dart';

class ModelManager extends ChangeNotifier {
  final ModelDownloadService _downloadService;

  ModelManifest? _manifest;
  ModelManifest? get manifest => _manifest;

  List<InstalledModelInfo> _installedModels = [];
  String? _selectedModelId;
  String? get selectedModelId => _selectedModelId;

  ModelManager({required ModelDownloadService downloadService})
      : _downloadService = downloadService;

  Future<ModelManifest> loadManifest() async {
    if (_manifest != null) return _manifest!;
    
    final jsonString = await rootBundle.loadString('assets/models/model_manifest.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    _manifest = ModelManifest.fromJson(jsonData);

    await _loadState();
    
    _selectedModelId ??= _manifest?.defaultModelId;
    
    notifyListeners();
    return _manifest!;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final modelsJson = prefs.getString('installed_models');
    if (modelsJson != null) {
      final List<dynamic> decoded = jsonDecode(modelsJson);
      _installedModels = decoded.map((e) => InstalledModelInfo.fromJson(e as Map<String, dynamic>)).toList();
    }

    _selectedModelId = prefs.getString('selected_model_id');
    
    // 実在確認
    final existingModels = <InstalledModelInfo>[];
    for (final info in _installedModels) {
      if (await _downloadService.isModelInstalled(info.filePath)) {
        existingModels.add(info);
      }
    }
    
    if (existingModels.length != _installedModels.length) {
      _installedModels = existingModels;
      await _saveState(prefs);
    }
    
    if (_selectedModelId != null && !_installedModels.any((m) => m.modelId == _selectedModelId)) {
      _selectedModelId = null;
      await _saveState(prefs);
    }
  }

  Future<void> _saveState([SharedPreferences? prefs]) async {
    prefs ??= await SharedPreferences.getInstance();
    await prefs.setString('installed_models', jsonEncode(_installedModels.map((e) => e.toJson()).toList()));
    if (_selectedModelId != null) {
      await prefs.setString('selected_model_id', _selectedModelId!);
    } else {
      await prefs.remove('selected_model_id');
    }
  }

  Future<List<InstalledModelInfo>> getInstalledModels() async {
    return _installedModels;
  }

  Future<InstalledModelInfo?> getSelectedModel() async {
    if (_selectedModelId == null) return null;
    try {
      return _installedModels.firstWhere((m) => m.modelId == _selectedModelId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isModelInstalled(String modelId) async {
    return _installedModels.any((m) => m.modelId == modelId);
  }

  Future<String?> getModelPath(String modelId) async {
    try {
      final info = _installedModels.firstWhere((m) => m.modelId == modelId);
      return info.filePath;
    } catch (_) {
      return null;
    }
  }

  Future<void> selectModel(String modelId) async {
    _selectedModelId = modelId;
    await _saveState();
    notifyListeners();
  }

  Future<void> deleteModel(String modelId) async {
    final index = _installedModels.indexWhere((m) => m.modelId == modelId);
    if (index >= 0) {
      final modelInfo = _installedModels[index];
      await _downloadService.deleteModel(modelInfo.filePath);
      _installedModels.removeAt(index);
      
      if (_selectedModelId == modelId) {
        _selectedModelId = null;
      }
      await _saveState();
      notifyListeners();
    }
  }

  Future<void> downloadModel(String modelId, {Function(double)? onProgress}) async {
    if (_manifest == null) await loadManifest();
    
    final modelEntry = _manifest!.models.firstWhere((m) => m.id == modelId);
    
    final destinationPath = await _downloadService.getModelDestinationPath(modelEntry.fileName);

    await _downloadService.downloadModel(
      modelEntry.downloadUrl,
      destinationPath,
      onProgress: onProgress,
    );


    _installedModels.add(InstalledModelInfo(
      modelId: modelId,
      filePath: destinationPath,
      fileSize: modelEntry.fileSizeBytes ?? 0,
      installedAt: DateTime.now(),
    ));

    await _saveState();
    notifyListeners();
  }
}
