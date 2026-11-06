import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final String type; // 'sale', 'expense', 'due_collection'
  final DateTime timestamp;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, title, subtitle, amount, type, timestamp];
}
