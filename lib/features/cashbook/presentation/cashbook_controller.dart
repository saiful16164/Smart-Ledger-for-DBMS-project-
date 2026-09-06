import 'package:smart_ledger/features/transactions/domain/models/transaction_model.dart';
import 'package:smart_ledger/features/transactions/presentation/transaction_controller.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cashbook_controller.g.dart';

class CashbookState {
  final List<TransactionModel> transactions;
  final DateTimeRange? dateRange;
  final String filter; // 'All', 'Income', 'Expense'

  CashbookState({
    required this.transactions,
    this.dateRange,
    this.filter = 'All',
  });

  CashbookState copyWith({
    List<TransactionModel>? transactions,
    DateTimeRange? dateRange,
    String? filter,
  }) {
    return CashbookState(
      transactions: transactions ?? this.transactions,
      dateRange: dateRange, // Nullable provided explicitly if needed
      filter: filter ?? this.filter,
    );
  }
}

@riverpod
class CashbookController extends _$CashbookController {
  @override
  FutureOr<CashbookState> build() async {
    // Initial fetch
    final repo = ref.watch(transactionRepositoryProvider);
    final transactions = await repo.getAllTransactions();
    return CashbookState(transactions: transactions);
  }

  Future<void> updateFilter(String filter) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic update of filter
    state = AsyncData(
      CashbookState(
        transactions: currentState.transactions, // Keep old for now
        dateRange: currentState.dateRange,
        filter: filter,
      ),
    );

    // Refetch
    await _fetchTransactions(filter: filter, dateRange: currentState.dateRange);
  }

  Future<void> updateDateRange(DateTimeRange? range) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      CashbookState(
        transactions: currentState.transactions,
        dateRange: range,
        filter: currentState.filter,
      ),
    );

    await _fetchTransactions(filter: currentState.filter, dateRange: range);
  }

  Future<void> _fetchTransactions({
    required String filter,
    DateTimeRange? dateRange,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      TransactionType? type;
      if (filter == 'Income') type = TransactionType.income;
      if (filter == 'Expense') type = TransactionType.expense;

      final transactions = await ref
          .read(transactionRepositoryProvider)
          .getAllTransactions(
            startDate: dateRange?.start,
            endDate: dateRange?.end,
            type: type,
          );

      return CashbookState(
        transactions: transactions,
        dateRange: dateRange,
        filter: filter,
      );
    });
  }
}
