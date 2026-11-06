import '../entities/dashboard_summary_entity.dart';
import '../entities/transaction_entity.dart';

abstract class DashboardRepository {
  Future<DashboardSummaryEntity> getDashboardSummary(String shopId);
  Future<List<TransactionEntity>> getRecentTransactions(String shopId);
}
