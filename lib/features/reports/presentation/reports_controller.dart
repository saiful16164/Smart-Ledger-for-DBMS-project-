import 'package:dbms_project/features/transactions/data/supabase_transaction_repository.dart';
import 'package:dbms_project/features/transactions/presentation/transaction_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reports_controller.g.dart';

class ReportState {
  final double income;
  final double expense;
  final double profit;
  final String period; // 'Week', 'Month', 'Year'

  ReportState({
    required this.income,
    required this.expense,
    required this.profit,
    required this.period,
  });
}

@riverpod
class ReportsController extends _$ReportsController {
  @override
  FutureOr<ReportState> build(String period) async {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    if (period == 'Week') {
      // Last 7 days
      startDate = now.subtract(const Duration(days: 7));
    } else if (period == 'Month') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      // Year
      startDate = DateTime(now.year, 1, 1);
    }

    final repo = ref.watch(transactionRepositoryProvider);
    final summary = await repo.getReportSummary(startDate, endDate);

    return ReportState(
      income: summary['income'] ?? 0.0,
      expense: summary['expense'] ?? 0.0,
      profit: summary['profit'] ?? 0.0,
      period: period,
    );
  }
}
