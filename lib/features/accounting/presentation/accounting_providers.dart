import 'package:smart_ledger/features/accounting/data/supabase_accounting_repository.dart';
import 'package:smart_ledger/features/accounting/domain/models/account_model.dart';
import 'package:smart_ledger/features/accounting/domain/models/accounting_report_models.dart';
import 'package:smart_ledger/features/accounting/domain/models/journal_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountsProvider = FutureProvider<List<AccountModel>>((ref) async {
  final repository = ref.watch(accountingRepositoryProvider);
  await repository.seedDefaultAccountsIfNeeded();
  return repository.getAccounts();
});

final journalEntriesProvider = FutureProvider<List<JournalEntryModel>>((
  ref,
) async {
  return ref.watch(accountingRepositoryProvider).getJournalEntries();
});

final trialBalanceProvider = FutureProvider<TrialBalanceModel>((ref) async {
  return ref.watch(accountingRepositoryProvider).getTrialBalance();
});

final ledgerRowsProvider =
    FutureProvider.family<List<LedgerRowModel>, AccountModel>((
      ref,
      account,
    ) async {
      return ref.watch(accountingRepositoryProvider).getLedgerRows(account);
    });
