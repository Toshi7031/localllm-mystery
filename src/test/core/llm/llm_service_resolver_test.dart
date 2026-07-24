import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:src/core/llm/llm_service_resolver.dart';
import 'package:src/core/llm/mock_llm_service.dart';
import 'package:src/core/model/model_download_service.dart';
import 'package:src/core/model/model_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LlmServiceResolver.createAndInitialize returns MockLlmService when no model selected', () async {
    SharedPreferences.setMockInitialValues({});
    final downloadService = MockModelDownloadService();
    final modelManager = ModelManager(downloadService: downloadService);
    
    final service = await LlmServiceResolver.createAndInitialize(modelManager);
    expect(service, isA<MockLlmService>());
  });
}
