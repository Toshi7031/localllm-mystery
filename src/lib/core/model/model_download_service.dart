import 'dart:async';

enum DownloadStatus {
  downloading,
  completed,
  failed,
  canceled,
  none,
}

class DownloadEvent {
  final String fileName;
  final DownloadStatus status;
  final double progress;
  final String? errorMessage;

  DownloadEvent({
    required this.fileName,
    required this.status,
    required this.progress,
    this.errorMessage,
  });
}

abstract class ModelDownloadService {
  Future<void> initialize();
  Future<String> getModelDestinationPath(String fileName);

  Future<void> downloadModel(String url, String destinationPath,
      {Function(double progress)? onProgress});
  Future<bool> deleteModel(String filePath);
  Future<bool> isModelInstalled(String filePath);

  Stream<DownloadEvent> get downloadEvents;
}

class MockModelDownloadService implements ModelDownloadService {
  final _eventController = StreamController<DownloadEvent>.broadcast();

  @override
  Future<void> initialize() async {
    // モックなので特になし
  }

  @override
  Stream<DownloadEvent> get downloadEvents => _eventController.stream;

  @override
  Future<String> getModelDestinationPath(String fileName) async {
    return 'dummy_path/$fileName';
  }

  @override
  Future<void> downloadModel(String url, String destinationPath,
      {Function(double progress)? onProgress}) async {
    final fileName = destinationPath.split('/').last;
    
    _eventController.add(DownloadEvent(
      fileName: fileName,
      status: DownloadStatus.downloading,
      progress: 0.0,
    ));

    // モックなので少し待って完了とする
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      final progress = i / 10.0;
      if (onProgress != null) {
        onProgress(progress);
      }
      
      _eventController.add(DownloadEvent(
        fileName: fileName,
        status: i == 10 ? DownloadStatus.completed : DownloadStatus.downloading,
        progress: progress,
      ));
    }
  }

  @override
  Future<bool> deleteModel(String filePath) async {
    // 常に成功
    return true;
  }

  @override
  Future<bool> isModelInstalled(String filePath) async {
    // デモ用に全て未インストールとするか、後でManagerで管理する
    return false;
  }
}
