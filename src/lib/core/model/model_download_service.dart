abstract class ModelDownloadService {
  Future<String> getModelDestinationPath(String fileName);

  Future<void> downloadModel(String url, String destinationPath,
      {Function(double progress)? onProgress});
  Future<bool> deleteModel(String filePath);
  Future<bool> isModelInstalled(String filePath);
}

class MockModelDownloadService implements ModelDownloadService {
  @override
  Future<String> getModelDestinationPath(String fileName) async {
    return 'dummy_path/$fileName';
  }

  @override
  Future<void> downloadModel(String url, String destinationPath,
      {Function(double progress)? onProgress}) async {
    // モックなので少し待って完了とする
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (onProgress != null) {
        onProgress(i / 10.0);
      }
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
