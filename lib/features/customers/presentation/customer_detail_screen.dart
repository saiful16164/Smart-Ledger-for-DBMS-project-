import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dbms_project/core/theme/app_colors.dart';
import 'package:dbms_project/features/customers/domain/models/customer_model.dart';
import 'package:dbms_project/features/customers/presentation/customer_controller.dart';
import 'package:dbms_project/features/customers/presentation/customer_detail_controller.dart';

import 'package:dbms_project/features/transactions/domain/models/transaction_model.dart';
import 'package:dbms_project/features/customers/presentation/widgets/add_customer_sheet.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  Future<void> _deleteCustomer(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      ref.read(customerControllerProvider.notifier).deleteCustomer(customer.id);
      context.pop(); // Go back to list
      // List will auto-refresh due to Riverpod watching the stream/provider
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for transactions
    final transactionsAsync = ref.watch(
      customerTransactionsProvider(customer.id),
    );

    // Watch for customer updates (e.g. balance change)
    final customersAsync = ref.watch(customerControllerProvider);
    final updatedCustomer = customersAsync.maybeWhen(
      data: (customers) {
        try {
          return customers.firstWhere((c) => c.id == customer.id);
        } catch (_) {
          return customer;
        }
      },
      orElse: () => customer,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedCustomer.name),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    AddCustomerSheet(customer: updatedCustomer),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _deleteCustomer(context, ref),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Delete Customer',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header / Profile Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    updatedCustomer.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${updatedCustomer.absBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  updatedCustomer.isReceivable
                      ? 'You will get'
                      : 'You will give',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.call,
                      label: 'Call',
                      onTap: () {},
                    ),
                    const SizedBox(width: 24),
                    _buildActionButton(
                      context,
                      icon: Icons.message,
                      label: 'SMS',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transaction History Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Hide View All if empty or handle navigation
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(child: Text('No transactions yet'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    // Income linked to customer means they PAID us (Balance reduction or Advance)
                    // Expense linked to customer means we gave them goods/money (Balance increase)
                    // Wait, let's stick to simple logic:
                    // Income: Money comes IN. Sale is Income.
                    // Expense: Money goes OUT.
                    // For a Store:
                    // Sale (Income) -> Customer owes us.
                    // Payment Received (Also Income? No, Payment Received reduces due).

                    // Let's refine logical mapping based on user mental model.
                    // User clicks "Received" -> Income.
                    // User clicks "Given" -> Expense.

                    final isIncome = transaction.type == TransactionType.income;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Note and Date
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    transaction.note?.isNotEmpty == true
                                        ? transaction.note!
                                        : (isIncome
                                              ? 'Payment Received'
                                              : 'Items Sold'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'dd MMM, hh:mm a',
                                  ).format(transaction.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            // Amount and Type
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isIncome ? 'Received' : 'Sold',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isIncome
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                                Text(
                                  isIncome
                                      ? '+ ৳${transaction.amount.toStringAsFixed(0)}'
                                      : '- ৳${transaction.amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isIncome
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
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
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              context
                  .push('/add-transaction', extra: {'customerId': customer.id})
                  .then(
                    (_) =>
                        ref.refresh(customerTransactionsProvider(customer.id)),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
