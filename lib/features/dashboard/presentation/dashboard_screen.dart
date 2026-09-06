import 'package:smart_ledger/features/dashboard/presentation/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ledger/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_ledger/features/customers/presentation/widgets/add_customer_sheet.dart';
import 'package:smart_ledger/features/transactions/domain/models/transaction_model.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Ledger'),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh manually
              ref.invalidate(dashboardControllerProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildSummaryCard(
                  context,
                  title: 'To Receive',
                  amount: NumberFormat.decimalPattern().format(stats.toReceive),
                  color: AppColors.success,
                  icon: Icons.arrow_downward,
                ),
                _buildSummaryCard(
                  context,
                  title: 'To Pay',
                  amount: NumberFormat.decimalPattern().format(stats.toPay),
                  color: AppColors.error,
                  icon: Icons.arrow_upward,
                ),
                _buildSummaryCard(
                  context,
                  title: 'Today\'s Sale',
                  amount: NumberFormat.decimalPattern().format(
                    stats.todaysSale,
                  ),
                  color: AppColors.info,
                  icon: Icons.point_of_sale,
                ),
                _buildSummaryCard(
                  context,
                  title: 'Cash in Hand',
                  amount: NumberFormat.decimalPattern().format(
                    stats.cashInHand,
                  ),
                  color: Colors.purple,
                  icon: Icons.account_balance_wallet,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  context,
                  'Add Customer',
                  Icons.person_add,
                  () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AddCustomerSheet(),
                    ).then((_) => ref.refresh(dashboardControllerProvider));
                  },
                ),
                _buildQuickAction(
                  context,
                  'Add Transaction',
                  Icons.receipt_long,
                  () {
                    context
                        .push('/add-transaction')
                        .then((_) => ref.refresh(dashboardControllerProvider));
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (stats.recentTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No recent transactions'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = stats.recentTransactions[index];
                  final isIncome = transaction.type == TransactionType.income;
                  // Use Customer Name or "Unknown"
                  final title =
                      transaction.customerName ??
                      (isIncome ? 'Cash Sale' : 'Expense');
                  final subtitle = DateFormat(
                    'MMM d, h:mm a',
                  ).format(transaction.date);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          (isIncome ? AppColors.success : AppColors.error)
                              .withOpacity(0.1),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? AppColors.success : AppColors.error,
                      ),
                    ),
                    title: Text(title),
                    subtitle: Text(subtitle),
                    trailing: Text(
                      '৳${NumberFormat.decimalPattern().format(transaction.amount)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? AppColors.success : AppColors.error,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '৳$amount',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
