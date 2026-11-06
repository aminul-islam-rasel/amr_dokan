import 'package:equatable/equatable.dart';

class DashboardSummaryEntity extends Equatable {
  final double todaysSales;
  final double todaysProfit;
  final double todaysExpenses;
  final double totalDue;
  final int totalProducts;
  final int totalCustomers;
  final int lowStockCount;

  const DashboardSummaryEntity({
    required this.todaysSales,
    required this.todaysProfit,
    required this.todaysExpenses,
    required this.totalDue,
    required this.totalProducts,
    required this.totalCustomers,
    required this.lowStockCount,
  });

  @override
  List<Object?> get props => [
        todaysSales,
        todaysProfit,
        todaysExpenses,
        totalDue,
        totalProducts,
        totalCustomers,
        lowStockCount,
      ];
}
