import 'model_manifest_entry.dart';

class ModelManifest {
  final int schemaVersion;
  final String defaultModelId;
  final List<ModelManifestEntry> models;

  const ModelManifest({
    required this.schemaVersion,
    required this.defaultModelId,
    required this.models,
  });

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    return ModelManifest(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      defaultModelId: json['defaultModelId'] as String? ?? '',
      models: (json['models'] as List<dynamic>?)
              ?.map((e) => ModelManifestEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
