import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'installed_model_info.dart';
import 'model_manifest.dart';
import 'model_manifest_entry.dart';
import 'model_download_service.dart';

class ModelManager extends ChangeNotifier {
  final ModelDownloadService _downloadService;
  StreamSubscription<DownloadEvent>? _downloadSubscription;

  ModelManifest? _manifest;
  ModelManifest? get manifest => _manifest;

  List<InstalledModelInfo> _installedModels = [];
  String? _selectedModelId;
  String? get selectedModelId => _selectedModelId;

  // ダウンロード進捗状況（0.0 〜 1.0）
  final Map<String, double> _downloadProgresses = {};
  // ダウンロード中かどうかのフラグ
  final Map<String, bool> _isDownloading = {};

  double getDownloadProgress(String modelId) => _downloadProgresses[modelId] ?? 0.0;
  bool isDownloading(String modelId) => _isDownloading[modelId] ?? false;

  ModelManager({required ModelDownloadService downloadService})
      : _downloadService = downloadService {
    _initDownloadListener();
  }

  void _initDownloadListener() {
    _downloadSubscription = _downloadService.downloadEvents.listen((event) {
      _handleDownloadEvent(event);
    });
  }

  void _handleDownloadEvent(DownloadEvent event) async {
    if (_manifest == null) {
      try {
        await loadManifest();
      } catch (_) {
        return;
      }
    }

    try {
      final modelEntry = _manifest?.models.firstWhere(
        (m) => m.fileName == event.fileName,
      );

      if (modelEntry == null) return;

      final modelId = modelEntry.id;

      switch (event.status) {
        case DownloadStatus.downloading:
          _isDownloading[modelId] = true;
          _downloadProgresses[modelId] = event.progress.clamp(0.0, 1.0);
          break;
        case DownloadStatus.completed:
          _isDownloading[modelId] = false;
          _downloadProgresses[modelId] = 1.0;
          
          if (!_installedModels.any((m) => m.modelId == modelId)) {
            final destinationPath = await _downloadService.getModelDestinationPath(modelEntry.fileName);
            _installedModels.add(InstalledModelInfo(
              modelId: modelId,
              filePath: destinationPath,
              fileSize: modelEntry.fileSizeBytes ?? 0,
              installedAt: DateTime.now(),
            ));
            await _saveState();
          }
          break;
        case DownloadStatus.failed:
        case DownloadStatus.canceled:
        case DownloadStatus.none:
          _isDownloading[modelId] = false;
          _downloadProgresses[modelId] = 0.0;
          break;
      }
      notifyListeners();
    } catch (_) {
      // マニフェストにないファイルイベントは無視
    }
  }

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
    
    // 実在確認とサイズチェック
    final existingModels = <InstalledModelInfo>[];
    for (final info in _installedModels) {
      if (await _downloadService.isModelInstalled(info.filePath)) {
        try {
          final file = File(info.filePath);
          final actualSize = await file.length();
          
          ModelManifestEntry? manifestEntry;
          if (_manifest != null) {
            try {
              manifestEntry = _manifest!.models.firstWhere((m) => m.id == info.modelId);
            } catch (_) {}
          }
          
          if (manifestEntry != null && manifestEntry.fileSizeBytes != null) {
            final expectedSize = manifestEntry.fileSizeBytes!;
            // 期待サイズの99%以上であればインストール済みとする（安全のために僅かなマージン）
            if (actualSize >= expectedSize * 0.99) {
              existingModels.add(info);
              continue;
            } else {
              developer.log(
                'Model file size mismatch for ${info.modelId}. Expected: $expectedSize, Actual: $actualSize. Deleting...',
                name: 'ModelManager',
              );
            }
          } else if (actualSize > 0) {
            // マニフェストに期待サイズが無い場合は、0バイトより大きければOKとする
            existingModels.add(info);
            continue;
          }
        } catch (e) {
          developer.log('Error verifying file ${info.filePath}: $e', name: 'ModelManager');
        }
      }
      
      // 実在しない、またはサイズ検証に失敗したモデルファイルはディスクから削除
      try {
        final file = File(info.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
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

  bool isModelInstalledSync(String modelId) {
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
    if (isDownloading(modelId)) return;
    
    final modelEntry = _manifest!.models.firstWhere((m) => m.id == modelId);
    final destinationPath = await _downloadService.getModelDestinationPath(modelEntry.fileName);

    _isDownloading[modelId] = true;
    _downloadProgresses[modelId] = 0.0;
    notifyListeners();

    try {
      await _downloadService.downloadModel(
        modelEntry.downloadUrl,
        destinationPath,
        onProgress: (p) {
          _downloadProgresses[modelId] = p.clamp(0.0, 1.0);
          notifyListeners();
          if (onProgress != null) {
            onProgress(p);
          }
        },
      );

      if (!_installedModels.any((m) => m.modelId == modelId)) {
        _installedModels.add(InstalledModelInfo(
          modelId: modelId,
          filePath: destinationPath,
          fileSize: modelEntry.fileSizeBytes ?? 0,
          installedAt: DateTime.now(),
        ));
        await _saveState();
      }
    } catch (e) {
      _downloadProgresses[modelId] = 0.0;
      rethrow;
    } finally {
      _isDownloading[modelId] = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel();
    super.dispose();
  }
}
