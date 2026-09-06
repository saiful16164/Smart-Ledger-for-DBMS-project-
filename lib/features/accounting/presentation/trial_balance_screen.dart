import 'package:smart_ledger/core/theme/app_colors.dart';
import 'package:smart_ledger/features/accounting/presentation/accounting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TrialBalanceScreen extends ConsumerWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trialBalanceAsync = ref.watch(trialBalanceProvider);
    final currency = NumberFormat.decimalPattern();

    return Scaffold(
      appBar: AppBar(title: const Text('Trial Balance')),
      body: trialBalanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load trial balance.\n$error'),
          ),
        ),
        data: (trialBalance) {
          if (trialBalance.rows.isEmpty) {
            return const Center(
              child: Text(
                'No accounting balances yet. Add transactions first.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(trialBalanceProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          trialBalance.isBalanced
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_outlined,
                          color: trialBalance.isBalanced
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            trialBalance.isBalanced
                                ? 'Trial balance is balanced'
                                : 'Difference: ৳${currency.format(trialBalance.difference.abs())}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      const _TrialBalanceHeader(),
                      const Divider(height: 1),
                      ...trialBalance.rows.map((row) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${row.account.code} - ${row.account.name}',
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  row.debit == 0
                                      ? '-'
                                      : '৳${currency.format(row.debit)}',
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  row.credit == 0
                                      ? '-'
                                      : '৳${currency.format(row.credit)}',
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 3,
                              child: Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '৳${currency.format(trialBalance.totalDebit)}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '৳${currency.format(trialBalance.totalCredit)}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrialBalanceHeader extends StatelessWidget {
  const _TrialBalanceHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Debit',
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Credit',
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
