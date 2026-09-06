import 'package:smart_ledger/features/accounting/data/supabase_accounting_repository.dart';
import 'package:smart_ledger/features/accounting/domain/models/journal_models.dart';
import 'package:smart_ledger/features/transactions/domain/models/transaction_model.dart';

class AccountingService {
  final SupabaseAccountingRepository _repository;

  AccountingService(this._repository);

  Future<void> createJournalFromTransaction(
    TransactionModel transaction,
  ) async {
    final alreadyExists = await _repository.hasJournalForSource(
      sourceType: 'transaction',
      sourceId: transaction.id,
    );
    if (alreadyExists) return;

    final accounts = await _repository.getDefaultAccountMap();
    final cash = accounts[DefaultAccountCodes.cash]!;
    final receivable = accounts[DefaultAccountCodes.accountsReceivable]!;
    final sales = accounts[DefaultAccountCodes.salesRevenue]!;
    final miscExpense = accounts[DefaultAccountCodes.miscExpense]!;

    final hasCustomer = transaction.customerId != null;
    final amount = transaction.amount;
    final narration = transaction.note?.trim().isNotEmpty == true
        ? transaction.note!.trim()
        : _defaultNarration(transaction);

    late final List<NewJournalLine> lines;

    if (hasCustomer && transaction.type == TransactionType.expense) {
      // Existing app label: Selling/Sold. Customer owes the business.
      lines = [
        NewJournalLine(accountId: receivable.id, debit: amount),
        NewJournalLine(accountId: sales.id, credit: amount),
      ];
    } else if (hasCustomer && transaction.type == TransactionType.income) {
      // Existing app label: Received/Got. Customer paid the business.
      lines = [
        NewJournalLine(accountId: cash.id, debit: amount),
        NewJournalLine(accountId: receivable.id, credit: amount),
      ];
    } else if (transaction.type == TransactionType.income) {
      // Cash sale or direct income.
      lines = [
        NewJournalLine(accountId: cash.id, debit: amount),
        NewJournalLine(accountId: sales.id, credit: amount),
      ];
    } else {
      // Cash expense.
      lines = [
        NewJournalLine(accountId: miscExpense.id, debit: amount),
        NewJournalLine(accountId: cash.id, credit: amount),
      ];
    }

    await _repository.createJournalEntry(
      date: transaction.date,
      narration: narration,
      sourceType: 'transaction',
      sourceId: transaction.id,
      lines: lines,
    );
  }

  String _defaultNarration(TransactionModel transaction) {
    if (transaction.customerId != null &&
        transaction.type == TransactionType.expense) {
      return 'Credit sale to customer';
    }
    if (transaction.customerId != null &&
        transaction.type == TransactionType.income) {
      return 'Payment received from customer';
    }
    return transaction.type == TransactionType.income
        ? 'Cash sale / income received'
        : 'Cash expense paid';
  }
}
