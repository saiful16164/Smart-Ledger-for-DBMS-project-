import 'package:dbms_project/features/cashbook/presentation/cashbook_controller.dart';
import 'package:dbms_project/features/transactions/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dbms_project/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class CashbookScreen extends ConsumerStatefulWidget {
  const CashbookScreen({super.key});

  @override
  ConsumerState<CashbookScreen> createState() => _CashbookScreenState();
}

class _CashbookScreenState extends ConsumerState<CashbookScreen> {
  // Local state purely for UI can be here, but we move logic to controller

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(cashbookControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashbook'),
        actions: [
          IconButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                ref
                    .read(cashbookControllerProvider.notifier)
                    .updateDateRange(picked);
              }
            },
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) => Column(
          children: [
            // Filters
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.backgroundLight,
              child: Row(
                children: [
                  _buildFilterChip('All', state.filter),
                  const SizedBox(width: 8),
                  _buildFilterChip('Income', state.filter),
                  const SizedBox(width: 8),
                  _buildFilterChip('Expense', state.filter),
                ],
              ),
            ),

            // Date Range Indicator
            if (state.dateRange != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: AppColors.primary.withOpacity(0.05),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('dd MMM').format(state.dateRange!.start)} - ${DateFormat('dd MMM').format(state.dateRange!.end)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        ref
                            .read(cashbookControllerProvider.notifier)
                            .updateDateRange(null);
                      },
                    ),
                  ],
                ),
              ),

            // Transaction List
            Expanded(
              child: state.transactions.isEmpty
                  ? const Center(child: Text("No transactions found"))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.transactions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        final isIncome =
                            transaction.type == TransactionType.income;
                        final amount = transaction.amount;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: isIncome
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            child: Icon(
                              isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isIncome
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            transaction.customerName ??
                                (isIncome ? 'Cash Sale' : 'Expense'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat(
                              'dd MMM yyyy, hh:mm a',
                            ).format(transaction.date),
                            style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          trailing: Text(
                            '${isIncome ? '+' : '-'}৳${NumberFormat.decimalPattern().format(amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isIncome
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context
              .push('/add-transaction', extra: {'type': TransactionType.income})
              .then((_) => ref.refresh(cashbookControllerProvider));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String currentFilter) {
    final isSelected = currentFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(cashbookControllerProvider.notifier).updateFilter(label);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
    );
  }
}
