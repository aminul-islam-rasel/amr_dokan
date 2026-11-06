import '../../domain/entities/transaction_entity.dart';

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final String type;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? json['customer_name'] ?? 'Sale',
      subtitle: json['subtitle'] ?? json['invoice_no'] ?? '',
      amount: (json['amount'] ?? json['total'] ?? 0.0).toDouble(),
      type: json['type'] ?? 'sale',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      amount: amount,
      type: type,
      timestamp: timestamp,
    );
  }
}
