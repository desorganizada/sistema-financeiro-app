class ImportResultModel {
  final int createdCount;
  final int skippedCount;
  final int errorsCount;
  final List<String> errors;

  ImportResultModel({
    required this.createdCount,
    required this.skippedCount,
    required this.errorsCount,
    required this.errors,
  });

  factory ImportResultModel.fromJson(Map<String, dynamic> json) {
    return ImportResultModel(
      createdCount: json['created_count'],
      skippedCount: json['skipped_count'],
      errorsCount: json['errors_count'],
      errors: List<String>.from(json['errors'] ?? []),
    );
  }
}