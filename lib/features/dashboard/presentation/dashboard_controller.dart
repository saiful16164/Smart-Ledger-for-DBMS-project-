import 'package:smart_ledger/features/customers/domain/models/customer_model.dart';
import 'package:smart_ledger/features/customers/presentation/customer_controller.dart';

import 'package:smart_ledger/features/transactions/domain/models/transaction_model.dart';
import 'package:smart_ledger/features/transactions/presentation/transaction_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_controller.g.dart';

class DashboardState {
  final double toReceive;
  final double toPay;
  final double todaysSale;
  final double cashInHand;
  final List<TransactionModel> recentTransactions;

  DashboardState({
    required this.toReceive,
    required this.toPay,
    required this.todaysSale,
    required this.cashInHand,
    required this.recentTransactions,
  });
}

@riverpod
class DashboardController extends _$DashboardController {
  @override
  FutureOr<DashboardState> build() async {
    // We watch the providers so that if they change (e.g. invalidate), we rebuild.
    // However, repositories are usually stateless singletons.
    // But we might want to listen to changes.
    // Ideally, we should listen to the STREAMS or rely on manual invalidation.
    // To keep it simple, we rely on ref.invalidate(dashboardControllerProvider) when actions happen.

    final customerRepo = ref.watch(customerRepositoryProvider);
    final transactionRepo = ref.watch(transactionRepositoryProvider);

    // Watch customer list to update stats when customers change
    // Using ref.watch(customerControllerProvider) might be better if it holds the list state.
    // If we rely on repository, we fetch fresh.
    // Let's rely on fresh fetch for dashboard to be accurate.

    final results = await Future.wait([
      customerRepo.getCustomers(),
      transactionRepo.getDailyIncome(DateTime.now()),
      transactionRepo.getCashInHand(),
      transactionRepo.getRecentTransactions(limit: 5),
    ]);

    final customers = results[0] as List<CustomerModel>;
    final todaysSale = results[1] as double;
    final cashInHand = results[2] as double;
    final recentTransactions = results[3] as List<TransactionModel>;

    double toReceive = 0;
    double toPay = 0;
    for (var c in customers) {
      if (c.totalDue > 0) toReceive += c.totalDue;
      if (c.totalDue < 0) toPay += c.totalDue.abs();
    }

    return DashboardState(
      toReceive: toReceive,
      toPay: toPay,
      todaysSale: todaysSale,
      cashInHand: cashInHand,
      recentTransactions: recentTransactions,
    );
  }
}
