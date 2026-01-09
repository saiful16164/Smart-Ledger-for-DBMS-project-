import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dbms_project/core/theme/app_colors.dart';
import 'package:dbms_project/features/customers/domain/models/customer_model.dart';
import 'package:dbms_project/features/ledger/domain/models/transaction_model.dart';
import 'package:intl/intl.dart';

class CustomerLedgerScreen extends ConsumerStatefulWidget {
  final CustomerModel customer;
  const CustomerLedgerScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerLedgerScreen> createState() =>
      _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends ConsumerState<CustomerLedgerScreen> {
  // Mock Transactions (Will replace later)

  // Mock Transactions
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: '1',
      customerId: '1',
      amount: 1000,
      type: TransactionType.sale, // Gave Product (Customer Owes)
      date: DateTime.now().subtract(const Duration(days: 2)),
      note: 'Rice 25kg',
    ),
    TransactionModel(
      id: '2',
      customerId: '1',
      amount: 500,
      type: TransactionType.payment, // Got Money (Customer Paid)
      date: DateTime.now().subtract(const Duration(days: 1)),
      note: 'Part payment',
    ),
    TransactionModel(
      id: '3',
      customerId: '1',
      amount: 4500,
      type: TransactionType.sale,
      date: DateTime.now(),
      note: 'Oil & Sugar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.customer.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.customer.phone ?? 'No Phone',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          // Sticky Balance Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Net Balance:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Due ৳${widget.customer.totalDue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final isSale = transaction.type == TransactionType.sale;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isSale
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSale
                              ? Colors.white
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSale
                                ? Colors.red.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isSale ? 'Sold' : 'Received',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSale
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'dd MMM, hh:mm a',
                                  ).format(transaction.date),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳${transaction.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (transaction.note != null &&
                                transaction.note!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                transaction.note!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add Sale (Red/Credit)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'GAVE (Sold)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add Payment (Green/Received)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'GOT (Received)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
