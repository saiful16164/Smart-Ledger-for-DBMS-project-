import 'package:smart_ledger/core/constants/supabase_constants.dart';
import 'package:smart_ledger/features/accounting/domain/models/account_model.dart';
import 'package:smart_ledger/features/accounting/domain/models/accounting_report_models.dart';
import 'package:smart_ledger/features/accounting/domain/models/journal_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final accountingRepositoryProvider = Provider<SupabaseAccountingRepository>((
  ref,
) {
  return SupabaseAccountingRepository(Supabase.instance.client);
});

class DefaultAccountCodes {
  static const cash = '1000';
  static const bank = '1010';
  static const accountsReceivable = '1100';
  static const inventory = '1200';
  static const accountsPayable = '2000';
  static const ownerCapital = '3000';
  static const ownerDrawings = '3100';
  static const salesRevenue = '4000';
  static const serviceRevenue = '4100';
  static const purchases = '5000';
  static const rentExpense = '5100';
  static const salaryExpense = '5200';
  static const utilitiesExpense = '5300';
  static const miscExpense = '5900';
}

class SupabaseAccountingRepository {
  final SupabaseClient _supabase;

  SupabaseAccountingRepository(this._supabase);

  String get _ownerId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.id;
  }

  static const List<Map<String, dynamic>> _defaultAccounts = [
    {'code': DefaultAccountCodes.cash, 'name': 'Cash', 'type': 'asset'},
    {'code': DefaultAccountCodes.bank, 'name': 'Bank', 'type': 'asset'},
    {
      'code': DefaultAccountCodes.accountsReceivable,
      'name': 'Accounts Receivable',
      'type': 'asset',
    },
    {
      'code': DefaultAccountCodes.inventory,
      'name': 'Inventory',
      'type': 'asset',
    },
    {
      'code': DefaultAccountCodes.accountsPayable,
      'name': 'Accounts Payable',
      'type': 'liability',
    },
    {
      'code': DefaultAccountCodes.ownerCapital,
      'name': 'Owner Capital',
      'type': 'equity',
    },
    {
      'code': DefaultAccountCodes.ownerDrawings,
      'name': 'Owner Drawings',
      'type': 'equity',
    },
    {
      'code': DefaultAccountCodes.salesRevenue,
      'name': 'Sales Revenue',
      'type': 'income',
    },
    {
      'code': DefaultAccountCodes.serviceRevenue,
      'name': 'Service Revenue',
      'type': 'income',
    },
    {
      'code': DefaultAccountCodes.purchases,
      'name': 'Purchases',
      'type': 'expense',
    },
    {
      'code': DefaultAccountCodes.rentExpense,
      'name': 'Rent Expense',
      'type': 'expense',
    },
    {
      'code': DefaultAccountCodes.salaryExpense,
      'name': 'Salary Expense',
      'type': 'expense',
    },
    {
      'code': DefaultAccountCodes.utilitiesExpense,
      'name': 'Utilities Expense',
      'type': 'expense',
    },
    {
      'code': DefaultAccountCodes.miscExpense,
      'name': 'Misc Expense',
      'type': 'expense',
    },
  ];

  Future<void> seedDefaultAccountsIfNeeded() async {
    final existing = await getAccounts();
    final existingCodes = existing.map((account) => account.code).toSet();
    final missing = _defaultAccounts
        .where((account) => !existingCodes.contains(account['code']))
        .map((account) => {...account, 'owner_id': _ownerId, 'is_system': true})
        .toList();

    if (missing.isNotEmpty) {
      await _supabase.from(SupabaseConstants.tableAccounts).insert(missing);
    }
  }

  Future<List<AccountModel>> getAccounts() async {
    final data = await _supabase
        .from(SupabaseConstants.tableAccounts)
        .select()
        .eq('owner_id', _ownerId)
        .order('code');

    return (data as List).map((row) => AccountModel.fromJson(row)).toList();
  }

  Future<AccountModel> createAccount({
    required String code,
    required String name,
    required AccountType type,
  }) async {
    final data = await _supabase
        .from(SupabaseConstants.tableAccounts)
        .insert({
          'owner_id': _ownerId,
          'code': code.trim(),
          'name': name.trim(),
          'type': type.value,
          'is_system': false,
        })
        .select()
        .single();

    return AccountModel.fromJson(data);
  }

  Future<Map<String, AccountModel>> getDefaultAccountMap() async {
    await seedDefaultAccountsIfNeeded();
    final accounts = await getAccounts();
    return {for (final account in accounts) account.code: account};
  }

  Future<bool> hasJournalForSource({
    required String sourceType,
    required String sourceId,
  }) async {
    final data = await _supabase
        .from(SupabaseConstants.tableJournalEntries)
        .select('id')
        .eq('owner_id', _ownerId)
        .eq('source_type', sourceType)
        .eq('source_id', sourceId)
        .limit(1);

    return (data as List).isNotEmpty;
  }

  Future<JournalEntryModel> createJournalEntry({
    required DateTime date,
    required String narration,
    required String sourceType,
    String? sourceId,
    required List<NewJournalLine> lines,
  }) async {
    final totalDebit = lines.fold<double>(0, (sum, line) => sum + line.debit);
    final totalCredit = lines.fold<double>(0, (sum, line) => sum + line.credit);
    if (lines.length < 2) {
      throw Exception('Journal entry must have at least two lines');
    }
    if (totalDebit <= 0 || totalCredit <= 0) {
      throw Exception('Journal entry must include debit and credit amounts');
    }
    if ((totalDebit - totalCredit).abs() > 0.01) {
      throw Exception('Journal entry is not balanced');
    }

    final entryData = await _supabase
        .from(SupabaseConstants.tableJournalEntries)
        .insert({
          'owner_id': _ownerId,
          'voucher_no': _buildVoucherNo(sourceType),
          'date': date.toIso8601String(),
          'narration': narration,
          'source_type': sourceType,
          'source_id': sourceId,
        })
        .select()
        .single();

    final entry = JournalEntryModel.fromJson(entryData);
    await _supabase
        .from(SupabaseConstants.tableJournalLines)
        .insert(
          lines
              .map(
                (line) => {
                  'journal_entry_id': entry.id,
                  'account_id': line.accountId,
                  'debit': line.debit,
                  'credit': line.credit,
                },
              )
              .toList(),
        );

    return entry;
  }

  Future<List<JournalEntryModel>> getJournalEntries({int limit = 100}) async {
    await seedDefaultAccountsIfNeeded();
    final entriesData = await _supabase
        .from(SupabaseConstants.tableJournalEntries)
        .select()
        .eq('owner_id', _ownerId)
        .order('date', ascending: false)
        .limit(limit);

    final entries = <JournalEntryModel>[];
    for (final entryData in entriesData as List) {
      final lines = await _getLinesForEntry(entryData['id'] as String);
      entries.add(JournalEntryModel.fromJson(entryData, lines: lines));
    }
    return entries;
  }

  Future<List<LedgerRowModel>> getLedgerRows(AccountModel account) async {
    await seedDefaultAccountsIfNeeded();
    final data = await _supabase
        .from(SupabaseConstants.tableJournalLines)
        .select('*, journal_entries(*)')
        .eq('account_id', account.id);

    final rows = (data as List).map((lineData) {
      final entry = lineData['journal_entries'] as Map<String, dynamic>;
      return (
        date: DateTime.parse(entry['date'] as String),
        voucherNo: entry['voucher_no'] as String,
        narration: entry['narration'] as String? ?? '',
        debit: (lineData['debit'] as num? ?? 0).toDouble(),
        credit: (lineData['credit'] as num? ?? 0).toDouble(),
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    double balance = 0;
    return rows.map((row) {
      balance += account.type.hasDebitNormalBalance
          ? row.debit - row.credit
          : row.credit - row.debit;
      return LedgerRowModel(
        date: row.date,
        voucherNo: row.voucherNo,
        particulars: row.narration,
        debit: row.debit,
        credit: row.credit,
        balance: balance,
      );
    }).toList();
  }

  Future<TrialBalanceModel> getTrialBalance() async {
    await seedDefaultAccountsIfNeeded();
    final accounts = await getAccounts();
    final rows = <TrialBalanceRowModel>[];

    for (final account in accounts) {
      final lineData = await _supabase
          .from(SupabaseConstants.tableJournalLines)
          .select('debit, credit')
          .eq('account_id', account.id);

      final debitTotal = (lineData as List).fold<double>(
        0,
        (sum, row) => sum + (row['debit'] as num? ?? 0).toDouble(),
      );
      final creditTotal = lineData.fold<double>(
        0,
        (sum, row) => sum + (row['credit'] as num? ?? 0).toDouble(),
      );
      final net = debitTotal - creditTotal;
      if (net.abs() > 0.01) {
        rows.add(
          TrialBalanceRowModel(
            account: account,
            debit: net > 0 ? net : 0,
            credit: net < 0 ? net.abs() : 0,
          ),
        );
      }
    }

    return TrialBalanceModel(rows);
  }

  Future<List<JournalLineModel>> _getLinesForEntry(String entryId) async {
    final data = await _supabase
        .from(SupabaseConstants.tableJournalLines)
        .select('*, accounts(*)')
        .eq('journal_entry_id', entryId)
        .order('debit', ascending: false);

    return (data as List).map((row) => JournalLineModel.fromJson(row)).toList();
  }

  String _buildVoucherNo(String sourceType) {
    final prefix = switch (sourceType) {
      'transaction' => 'TXN',
      'manual' => 'JV',
      _ => 'JV',
    };
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}';
  }
}
