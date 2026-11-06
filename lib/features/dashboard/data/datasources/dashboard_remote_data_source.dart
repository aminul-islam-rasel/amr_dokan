import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_summary_model.dart';
import '../models/transaction_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getDashboardSummary(String shopId);
  Future<List<TransactionModel>> getRecentTransactions(String shopId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient _dioClient;

  DashboardRemoteDataSourceImpl(this._dioClient);

  @override
  Future<DashboardSummaryModel> getDashboardSummary(String shopId) async {
    try {
      final response = await _dioClient.get(
        '/shops/$shopId/dashboard/summary',
      );
      return DashboardSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback mock data for development & MVP testing if endpoint not yet deployed
        return DashboardSummaryModel(
          todaysSales: 14500,
          todaysProfit: 3200,
          todaysExpenses: 450,
          totalDue: 6800,
          totalProducts: 142,
          totalCustomers: 58,
          lowStockCount: 3,
        );
      }
      throw e.error ?? e;
    }
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions(String shopId) async {
    try {
      final response = await _dioClient.get(
        '/shops/$shopId/dashboard/transactions',
      );
      final List data = response.data is List ? response.data : (response.data['transactions'] ?? []);
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback mock transactions for development & MVP testing
        return [
          TransactionModel(
            id: '1',
            title: 'রকিব হোসেন',
            subtitle: 'ইনভয়েস #INV-1042',
            amount: 1250,
            type: 'sale',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
          TransactionModel(
            id: '2',
            title: 'দোকান ভাড়া প্রদান',
            subtitle: 'মাসিক খরচ',
            amount: 5000,
            type: 'expense',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          TransactionModel(
            id: '3',
            title: 'করিম মিয়া (বাকি আদায়)',
            subtitle: 'বাকি পরিশোধ',
            amount: 800,
            type: 'due_collection',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ];
      }
      throw e.error ?? e;
    }
  }
}
