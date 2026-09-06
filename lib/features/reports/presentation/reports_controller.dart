import 'package:smart_ledger/features/transactions/domain/models/transaction_model.dart';
import 'package:smart_ledger/features/transactions/presentation/transaction_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reports_controller.g.dart';

// Data point for daily chart
class DailyData {
  final DateTime date;
  final double income;
  final double expense;

  DailyData({required this.date, required this.income, required this.expense});
}

class ReportState {
  final double income;
  final double expense;
  final double profit;
  final String period; // 'Week', 'Month', 'Year'
  final List<DailyData> dailyData; // For bar chart
  final List<TransactionModel> transactions; // For pie chart breakdown

  ReportState({
    required this.income,
    required this.expense,
    required this.profit,
    required this.period,
    required this.dailyData,
    required this.transactions,
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

    // Fetch all transactions for the period
    final transactions = await repo.getAllTransactions(
      startDate: startDate,
      endDate: endDate,
    );

    // Generate daily data for charts
    final dailyData = _generateDailyData(
      transactions,
      startDate,
      endDate,
      period,
    );

    return ReportState(
      income: summary['income'] ?? 0.0,
      expense: summary['expense'] ?? 0.0,
      profit: summary['profit'] ?? 0.0,
      period: period,
      dailyData: dailyData,
      transactions: transactions,
    );
  }

  List<DailyData> _generateDailyData(
    List<TransactionModel> transactions,
    DateTime startDate,
    DateTime endDate,
    String period,
  ) {
    final Map<String, DailyData> dataMap = {};

    // Initialize dates based on period
    if (period == 'Week') {
      // Last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final key = '${date.year}-${date.month}-${date.day}';
        dataMap[key] = DailyData(date: date, income: 0, expense: 0);
      }
    } else if (period == 'Month') {
      // Days of current month
      final daysInMonth = DateTime(endDate.year, endDate.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(endDate.year, endDate.month, i);
        if (date.isAfter(endDate)) break;
        final key = '${date.year}-${date.month}-${date.day}';
        dataMap[key] = DailyData(date: date, income: 0, expense: 0);
      }
    } else {
      // Year - group by month
      for (int i = 1; i <= 12; i++) {
        final date = DateTime(endDate.year, i, 1);
        if (date.isAfter(endDate)) break;
        final key = '${date.year}-${date.month}';
        dataMap[key] = DailyData(date: date, income: 0, expense: 0);
      }
    }

    // Aggregate transaction data
    for (final tx in transactions) {
      String key;
      if (period == 'Year') {
        key = '${tx.date.year}-${tx.date.month}';
      } else {
        key = '${tx.date.year}-${tx.date.month}-${tx.date.day}';
      }

      if (dataMap.containsKey(key)) {
        final existing = dataMap[key]!;
        if (tx.type == TransactionType.income) {
          dataMap[key] = DailyData(
            date: existing.date,
            income: existing.income + tx.amount,
            expense: existing.expense,
          );
        } else {
          dataMap[key] = DailyData(
            date: existing.date,
            income: existing.income,
            expense: existing.expense + tx.amount,
          );
        }
      }
    }

    return dataMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }
}
