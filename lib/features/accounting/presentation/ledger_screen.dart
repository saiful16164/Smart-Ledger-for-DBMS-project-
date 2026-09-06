import 'package:smart_ledger/core/theme/app_colors.dart';
import 'package:smart_ledger/features/accounting/domain/models/account_model.dart';
import 'package:smart_ledger/features/accounting/presentation/accounting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  AccountModel? _selectedAccount;

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ledger')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load accounts.\n$error')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No accounts found.'));
          }

          final selected = accounts.firstWhere(
            (account) => account.id == _selectedAccount?.id,
            orElse: () => accounts.first,
          );
          if (_selectedAccount?.id != selected.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedAccount = selected);
            });
          }

          final rowsAsync = ref.watch(ledgerRowsProvider(selected));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<AccountModel>(
                  value: selected,
                  decoration: const InputDecoration(
                    labelText: 'Select Account',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  items: accounts.map((account) {
                    return DropdownMenuItem(
                      value: account,
                      child: Text('${account.code} - ${account.name}'),
                    );
                  }).toList(),
                  onChanged: (account) {
                    if (account != null) {
                      setState(() => _selectedAccount = account);
                    }
                  },
                ),
              ),
              Expanded(
                child: rowsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Unable to load ledger.\n$error')),
                  data: (rows) {
                    if (rows.isEmpty) {
                      return const Center(
                        child: Text('No ledger entries for this account.'),
                      );
                    }

                    final currency = NumberFormat.decimalPattern();
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      row.voucherNo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(row.date),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(row.particulars),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _AmountColumn(
                                      label: 'Debit',
                                      value: row.debit,
                                      color: AppColors.success,
                                      currency: currency,
                                    ),
                                    _AmountColumn(
                                      label: 'Credit',
                                      value: row.credit,
                                      color: AppColors.error,
                                      currency: currency,
                                    ),
                                    _AmountColumn(
                                      label: 'Balance',
                                      value: row.balance,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      currency: currency,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final NumberFormat currency;

  const _AmountColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          value == 0 ? '-' : '৳${currency.format(value.abs())}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
