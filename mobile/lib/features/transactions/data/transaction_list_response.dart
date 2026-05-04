// lib/features/transactions/data/transaction_list_response.dart

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
    // Garante que a lista de items seja tratada corretamente
    List<TransactionModel> transactionItems = [];
    
    if (json['items'] != null && json['items'] is List) {
      transactionItems = (json['items'] as List)
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return TransactionListResponse(
      items: transactionItems,
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }
}