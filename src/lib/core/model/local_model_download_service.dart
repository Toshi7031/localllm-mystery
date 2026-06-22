import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'model_download_service.dart';

class LocalModelDownloadService implements ModelDownloadService {
  final http.Client _client = http.Client();

  @override
  Future<void> downloadModel(String url, String destinationPath,
      {Function(double progress)? onProgress}) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to download model: ${response.statusCode}');
    }

    final contentLength = response.contentLength;
    int bytesReceived = 0;

    final file = File(destinationPath);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final sink = file.openWrite();

    await for (final chunk in response.stream) {
      sink.add(chunk);
      bytesReceived += chunk.length;
      if (contentLength != null && onProgress != null) {
        onProgress(bytesReceived / contentLength);
      }
    }

    await sink.flush();
    await sink.close();
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
