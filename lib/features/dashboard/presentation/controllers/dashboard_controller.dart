import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/shared_prefs_service.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/entities/transaction_entity.dart';

final dashboardDataProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
  final shopId = sharedPrefs.getString(AppConstants.prefKeyActiveShopId) ?? 'default_shop';

  final summary = await repo.getDashboardSummary(shopId);
  final transactions = await repo.getRecentTransactions(shopId);

  return DashboardData(summary: summary, transactions: transactions);
});

class DashboardData {
  final DashboardSummaryEntity summary;
  final List<TransactionEntity> transactions;

  DashboardData({required this.summary, required this.transactions});
}
