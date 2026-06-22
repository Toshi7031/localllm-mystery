class ModelManifestEntry {
  final String id;
  final String displayName;
  final String description;
  final String family;
  final String modelName;
  final String parameterSize;
  final String quantization;
  final String format;
  final String fileName;
  final int? fileSizeBytes;
  final int recommendedMemoryMb;
  final int minimumFreeStorageMb;
  final String downloadUrl;
  final String sha256;
  final String licenseName;
  final String licenseUrl;
  final String sourceUrl;
  final String notes;

  const ModelManifestEntry({
    required this.id,
    required this.displayName,
    required this.description,
    required this.family,
    required this.modelName,
    required this.parameterSize,
    required this.quantization,
    required this.format,
    required this.fileName,
    this.fileSizeBytes,
    required this.recommendedMemoryMb,
    required this.minimumFreeStorageMb,
    required this.downloadUrl,
    required this.sha256,
    required this.licenseName,
    required this.licenseUrl,
    required this.sourceUrl,
    required this.notes,
  });

  factory ModelManifestEntry.fromJson(Map<String, dynamic> json) {
    return ModelManifestEntry(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      family: json['family'] as String? ?? '',
      modelName: json['modelName'] as String? ?? '',
      parameterSize: json['parameterSize'] as String? ?? '',
      quantization: json['quantization'] as String? ?? '',
      format: json['format'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileSizeBytes: json['fileSizeBytes'] as int?,
      recommendedMemoryMb: json['recommendedMemoryMb'] as int? ?? 0,
      minimumFreeStorageMb: json['minimumFreeStorageMb'] as int? ?? 0,
      downloadUrl: json['downloadUrl'] as String? ?? '',
      sha256: json['sha256'] as String? ?? '',
      licenseName: json['licenseName'] as String? ?? '',
      licenseUrl: json['licenseUrl'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}
