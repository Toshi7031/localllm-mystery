import 'dart:async';
import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'model_download_service.dart';

class LocalModelDownloadService implements ModelDownloadService {
  final _eventController = StreamController<DownloadEvent>.broadcast();

  @override
  Stream<DownloadEvent> get downloadEvents => _eventController.stream;

  @override
  Future<void> initialize() async {
    // 過去の未完了タスクの追跡設定を有効化し、 updates ストリームを有効にする
    await FileDownloader().trackTasks();

    FileDownloader().updates.listen((update) {
      if (update is TaskStatusUpdate) {
        _handleStatusUpdate(update);
      } else if (update is TaskProgressUpdate) {
        _handleProgressUpdate(update);
      }
    });
  }

  void _handleStatusUpdate(TaskStatusUpdate update) {
    final status = _mapStatus(update.status);
    final progress = status == DownloadStatus.completed ? 1.0 : 0.0;
    _eventController.add(DownloadEvent(
      fileName: update.task.filename,
      status: status,
      progress: progress,
      errorMessage: update.exception?.description,
    ));
  }

  void _handleProgressUpdate(TaskProgressUpdate update) {
    _eventController.add(DownloadEvent(
      fileName: update.task.filename,
      status: DownloadStatus.downloading,
      progress: update.progress,
    ));
  }

  DownloadStatus _mapStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.enqueued:
      case TaskStatus.running:
        return DownloadStatus.downloading;
      case TaskStatus.complete:
        return DownloadStatus.completed;
      case TaskStatus.failed:
        return DownloadStatus.failed;
      case TaskStatus.canceled:
        return DownloadStatus.canceled;
      default:
        return DownloadStatus.none;
    }
  }

  @override
  Future<void> downloadModel(String url, String destinationPath,
      {Function(double progress)? onProgress}) async {
    final file = File(destinationPath);
    final fileName = file.path.split('/').last;

    // 保存先ディレクトリ models が無ければ作成
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final task = DownloadTask(
      url: url,
      filename: fileName,
      directory: 'models',
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      retries: 3,
    );

    // downloadメソッドでフォアグラウンド完了を監視。
    // updatesストリーム側にもバックグラウンドの進捗が流れるため、
    // アプリがバックグラウンドに移動したりキルされた際にも、
    // ネイティブ側でダウンロードが継続され、再起動時やイベント購読で処理されます。
    await FileDownloader().download(
      task,
      onProgress: (progress) {
        if (onProgress != null) {
          onProgress(progress);
        }
      },
    );
  }

  @override
  Future<bool> deleteModel(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  @override
  Future<bool> isModelInstalled(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  @override
  Future<String> getModelDestinationPath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${directory.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return '${modelsDir.path}/$fileName';
  }
}
