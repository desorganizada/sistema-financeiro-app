import 'transaction_model.dart';

class TransactionListResponse {
  final List<TransactionModel> items;
  final int total;
  final int limit;
  final int offset;

  TransactionListResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      items: (json['items'] as List)
          .map((item) => TransactionModel.fromJson(item))
          .toList(),
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
    );
  }
}