import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DashboardRemoteDataSourceImpl(dioClient);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(remoteDataSource);
});

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<DashboardSummaryEntity> getDashboardSummary(String shopId) async {
    final model = await _remoteDataSource.getDashboardSummary(shopId);
    return model.toEntity();
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions(String shopId) async {
    final models = await _remoteDataSource.getRecentTransactions(shopId);
    return models.map((m) => m.toEntity()).toList();
  }
}
