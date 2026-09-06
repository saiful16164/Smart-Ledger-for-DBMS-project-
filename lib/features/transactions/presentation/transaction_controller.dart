import 'package:smart_ledger/features/accounting/data/accounting_service.dart';
import 'package:smart_ledger/features/accounting/data/supabase_accounting_repository.dart';
import 'package:smart_ledger/features/customers/presentation/customer_controller.dart';
import 'package:smart_ledger/features/transactions/data/supabase_transaction_repository.dart';
import 'package:smart_ledger/features/transactions/domain/models/transaction_model.dart';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'transaction_controller.g.dart';

@riverpod
SupabaseTransactionRepository transactionRepository(
  TransactionRepositoryRef ref,
) {
  return SupabaseTransactionRepository(Supabase.instance.client);
}

@riverpod
class TransactionController extends _$TransactionController {
  @override
  FutureOr<List<TransactionModel>> build() {
    return ref.watch(transactionRepositoryProvider).getRecentTransactions();
  }

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    String? customerId,
    String? note,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Add Transaction
      final transaction = await ref
          .read(transactionRepositoryProvider)
          .addTransaction(
            amount: amount,
            type: type,
            customerId: customerId,
            note: note,
            date: date,
          );

      // 2. Update Customer Balance if applicable
      if (customerId != null) {
        // Expense = We gave money/goods = totalGiven increases (Receivable increases)
        // Income = We received money = totalReceived increases
        final isGiven = type == TransactionType.expense;

        await ref
            .read(customerRepositoryProvider)
            .updateBalance(
              customerId: customerId,
              amount: amount,
              isGiven: isGiven,
            );

        // Invalidate customer list to reflect balance changes
        ref.invalidate(customerControllerProvider);
      }

      // 3. Create accounting journal in the background.
      // If accounting tables are not created yet, keep existing transaction flow working.
      try {
        await AccountingService(
          ref.read(accountingRepositoryProvider),
        ).createJournalFromTransaction(transaction);
      } catch (e) {
        debugPrint('Accounting journal creation skipped: $e');
      }

      // 4. Refresh self (recent transactions)
      return ref.refresh(transactionRepositoryProvider).getRecentTransactions();
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}
