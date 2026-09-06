import 'package:smart_ledger/core/theme/app_colors.dart';
import 'package:smart_ledger/features/accounting/data/accounting_service.dart';
import 'package:smart_ledger/features/accounting/data/supabase_accounting_repository.dart';
import 'package:smart_ledger/features/accounting/domain/models/account_model.dart';
import 'package:smart_ledger/features/accounting/domain/models/journal_models.dart';
import 'package:smart_ledger/features/accounting/presentation/accounting_providers.dart';
import 'package:smart_ledger/features/transactions/presentation/transaction_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);
    final currency = NumberFormat.decimalPattern();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            tooltip: 'Sync old transactions',
            onPressed: () => _syncTransactions(context, ref),
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showManualJournalSheet(context, ref),
        icon: const Icon(Icons.edit_note),
        label: const Text('Manual Entry'),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load journal entries.\n$error'),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No journal entries yet. Add a transaction or create a manual entry.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(journalEntriesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final total = entry.lines.fold<double>(
                  0,
                  (sum, line) => sum + line.debit,
                );

                return Card(
                  child: ExpansionTile(
                    title: Text(
                      entry.voucherNo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${DateFormat('dd MMM yyyy').format(entry.date)} • ${entry.narration}',
                    ),
                    trailing: Text(
                      '৳${currency.format(total)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: entry.lines.map((line) {
                            final isDebit = line.debit > 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${isDebit ? 'Dr.' : 'Cr.'} ${line.account?.name ?? 'Unknown Account'}',
                                      style: TextStyle(
                                        fontWeight: isDebit
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '৳${currency.format(isDebit ? line.debit : line.credit)}',
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showManualJournalSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ManualJournalSheet(ref: ref),
    );
  }

  Future<void> _syncTransactions(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final transactions = await ref
          .read(transactionRepositoryProvider)
          .getAllTransactions();
      final service = AccountingService(ref.read(accountingRepositoryProvider));
      for (final transaction in transactions) {
        await service.createJournalFromTransaction(transaction);
      }
      _invalidateAccountingReports(ref);
      messenger.showSnackBar(
        const SnackBar(content: Text('Accounting journals synced.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _invalidateAccountingReports(WidgetRef ref) {
    ref.invalidate(journalEntriesProvider);
    ref.invalidate(trialBalanceProvider);
    ref.invalidate(accountsProvider);
  }
}

class _ManualJournalSheet extends StatefulWidget {
  final WidgetRef ref;

  const _ManualJournalSheet({required this.ref});

  @override
  State<_ManualJournalSheet> createState() => _ManualJournalSheetState();
}

class _ManualJournalSheetState extends State<_ManualJournalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();
  AccountModel? _debitAccount;
  AccountModel? _creditAccount;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_debitAccount?.id == _creditAccount?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debit and credit accounts must be different.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final amount = double.parse(_amountController.text.trim());

    try {
      await widget.ref
          .read(accountingRepositoryProvider)
          .createJournalEntry(
            date: DateTime.now(),
            narration: _narrationController.text.trim().isEmpty
                ? 'Manual journal entry'
                : _narrationController.text.trim(),
            sourceType: 'manual',
            lines: [
              NewJournalLine(accountId: _debitAccount!.id, debit: amount),
              NewJournalLine(accountId: _creditAccount!.id, credit: amount),
            ],
          );
      widget.ref.invalidate(journalEntriesProvider);
      widget.ref.invalidate(trialBalanceProvider);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Manual journal entry posted.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Unable to post journal entry: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = widget.ref.watch(accountsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: accountsAsync.when(
        loading: () => const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Text('Unable to load accounts.\n$error'),
        data: (accounts) {
          if (accounts.length < 2) {
            return const Text('Create at least two accounts first.');
          }

          _debitAccount ??= accounts.first;
          _creditAccount ??= accounts.firstWhere(
            (account) => account.id != _debitAccount!.id,
            orElse: () => accounts.last,
          );

          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Manual Journal Entry',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<AccountModel>(
                  value: _debitAccount,
                  decoration: const InputDecoration(
                    labelText: 'Debit Account',
                    prefixIcon: Icon(Icons.south_west),
                  ),
                  items: _accountItems(accounts),
                  onChanged: (account) => setState(() {
                    _debitAccount = account;
                  }),
                  validator: (value) =>
                      value == null ? 'Select debit account' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AccountModel>(
                  value: _creditAccount,
                  decoration: const InputDecoration(
                    labelText: 'Credit Account',
                    prefixIcon: Icon(Icons.north_east),
                  ),
                  items: _accountItems(accounts),
                  onChanged: (account) => setState(() {
                    _creditAccount = account;
                  }),
                  validator: (value) =>
                      value == null ? 'Select credit account' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _narrationController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Narration',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Post Entry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<DropdownMenuItem<AccountModel>> _accountItems(
    List<AccountModel> accounts,
  ) {
    return accounts
        .map(
          (account) => DropdownMenuItem(
            value: account,
            child: Text('${account.code} - ${account.name}'),
          ),
        )
        .toList();
  }
}
