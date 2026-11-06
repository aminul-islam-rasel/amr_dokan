import '../../domain/entities/dashboard_summary_entity.dart';

class DashboardSummaryModel {
  final double todaysSales;
  final double todaysProfit;
  final double todaysExpenses;
  final double totalDue;
  final int totalProducts;
  final int totalCustomers;
  final int lowStockCount;

  DashboardSummaryModel({
    required this.todaysSales,
    required this.todaysProfit,
    required this.todaysExpenses,
    required this.totalDue,
    required this.totalProducts,
    required this.totalCustomers,
    required this.lowStockCount,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      todaysSales: (json['todays_sales'] ?? json['sales'] ?? 0.0).toDouble(),
      todaysProfit: (json['todays_profit'] ?? json['profit'] ?? 0.0).toDouble(),
      todaysExpenses: (json['todays_expenses'] ?? json['expenses'] ?? 0.0).toDouble(),
      totalDue: (json['total_due'] ?? json['due'] ?? 0.0).toDouble(),
      totalProducts: json['total_products'] ?? json['products_count'] ?? 0,
      totalCustomers: json['total_customers'] ?? json['customers_count'] ?? 0,
      lowStockCount: json['low_stock_count'] ?? json['low_stock'] ?? 0,
    );
  }

  DashboardSummaryEntity toEntity() {
    return DashboardSummaryEntity(
      todaysSales: todaysSales,
      todaysProfit: todaysProfit,
      todaysExpenses: todaysExpenses,
      totalDue: totalDue,
      totalProducts: totalProducts,
      totalCustomers: totalCustomers,
      lowStockCount: lowStockCount,
    );
  }
}
