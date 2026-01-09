import 'package:dbms_project/features/customers/presentation/customer_detail_controller.dart';
import 'package:dbms_project/features/transactions/presentation/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dbms_project/core/theme/app_colors.dart';
import 'package:dbms_project/features/customers/domain/models/customer_model.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for transactions
    final transactionsAsync = ref.watch(
      customerTransactionsProvider(customer.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
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
                    customer.name.substring(0, 1).toUpperCase(),
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
                  '৳${customer.absBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  customer.isReceivable ? 'You will get' : 'You will give',
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

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        transaction.note ?? (isIncome ? 'Received' : 'Given'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM hh:mm a').format(transaction.date),
                        style: const TextStyle(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      trailing: Text(
                        '৳${transaction.amount}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isIncome ? AppColors.success : AppColors.error,
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
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context
                      .push(
                        '/add-transaction',
                        extra: {
                          'type': TransactionType.income,
                          'customerId': customer.id,
                        },
                      )
                      .then(
                        (_) => ref.refresh(
                          customerTransactionsProvider(customer.id),
                        ),
                      );
                },
                icon: const Icon(Icons.add),
                label: const Text('Received'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context
                      .push(
                        '/add-transaction',
                        extra: {
                          'type': TransactionType.expense,
                          'customerId': customer.id,
                        },
                      )
                      .then(
                        (_) => ref.refresh(
                          customerTransactionsProvider(customer.id),
                        ),
                      );
                },
                icon: const Icon(Icons.remove),
                label: const Text('Given'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
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
