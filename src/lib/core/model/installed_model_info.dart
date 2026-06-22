class InstalledModelInfo {
  final String modelId;
  final String filePath;
  final int fileSize;
  final DateTime installedAt;

  const InstalledModelInfo({
    required this.modelId,
    required this.filePath,
    required this.fileSize,
    required this.installedAt,
  });

  factory InstalledModelInfo.fromJson(Map<String, dynamic> json) {
    return InstalledModelInfo(
      modelId: json['modelId'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      installedAt: DateTime.parse(json['installedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'filePath': filePath,
      'fileSize': fileSize,
      'installedAt': installedAt.toIso8601String(),
    };
  }
}
