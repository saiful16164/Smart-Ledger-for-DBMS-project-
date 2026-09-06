import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ledger/core/theme/app_colors.dart';
import 'package:smart_ledger/core/services/email_service.dart';
import 'package:smart_ledger/features/customers/presentation/customer_controller.dart';
import 'package:smart_ledger/features/transactions/presentation/transaction_controller.dart';
import 'package:smart_ledger/features/transactions/domain/models/transaction_model.dart';
import 'package:smart_ledger/features/settings/presentation/profile_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? initialCustomerId;

  const AddTransactionScreen({super.key, this.initialCustomerId});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _givenController = TextEditingController();
  final _receivedController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCustomerId;
  bool _isSendingEmail = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;
    _dateController.text = DateFormat('dd MMM yyyy').format(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerControllerProvider);
    final transactionState = ref.watch(transactionControllerProvider);
    final isLoading = transactionState.isLoading || _isSendingEmail;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Customer Selector
                customersAsync.when(
                  data: (customers) {
                    return DropdownButtonFormField<String>(
                      value: _selectedCustomerId,
                      decoration: const InputDecoration(
                        labelText: 'Select Party / Customer',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items: customers.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomerId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a customer' : null,
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading customers: $err'),
                ),
                const SizedBox(height: 24),

                // Dual Inputs: Selling (Given) / Received (Got)
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountField(
                        controller: _givenController,
                        label: 'Selling (Sold)',
                        color: AppColors.error,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAmountField(
                        controller: _receivedController,
                        label: 'Received (Got)',
                        color: AppColors.success,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (Description)',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Picker
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _dateController.text = DateFormat(
                          'dd MMM yyyy',
                        ).format(picked);
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : _saveTransaction,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Transaction',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField({
    required TextEditingController controller,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color),
            prefixText: '৳ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            hintText: '0',
          ),
        ),
      ],
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final givenText = _givenController.text.trim();
    final receivedText = _receivedController.text.trim();

    final givenAmount = double.tryParse(givenText) ?? 0;
    final receivedAmount = double.tryParse(receivedText) ?? 0;

    if (givenAmount == 0 && receivedAmount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final controller = ref.read(transactionControllerProvider.notifier);

      // 1. Process "Given" (Expense)
      if (givenAmount > 0) {
        await controller.addTransaction(
          amount: givenAmount,
          type: TransactionType.expense,
          customerId: _selectedCustomerId,
          date: _selectedDate,
          note: _noteController.text.isEmpty ? 'Given' : _noteController.text,
        );
      }

      // 2. Process "Received" (Income)
      if (receivedAmount > 0) {
        await controller.addTransaction(
          amount: receivedAmount,
          type: TransactionType.income,
          customerId: _selectedCustomerId,
          date: _selectedDate,
          note: _noteController.text.isEmpty
              ? 'Received'
              : _noteController.text,
        );
      }

      // 3. Calculate Net Amount (Given - Received = Amount customer owes)
      final netAmount = givenAmount - receivedAmount;

      // 4. If customer owes money (net > 0), send payment reminder email
      if (netAmount > 0 && _selectedCustomerId != null) {
        await _sendPaymentReminderEmail(netAmount);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              netAmount > 0
                  ? 'Transaction saved! Payment reminder sent.'
                  : 'Transaction(s) saved successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendPaymentReminderEmail(double amountOwed) async {
    setState(() => _isSendingEmail = true);

    try {
      // Get the customer details
      final customers = ref.read(customerControllerProvider).valueOrNull ?? [];
      final customer = customers.firstWhere(
        (c) => c.id == _selectedCustomerId,
        orElse: () => throw Exception('Customer not found'),
      );

      // Check if customer has email
      if (customer.email == null || customer.email!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer has no email address. Skipping email.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get store name from profile
      final profile = ref.read(profileControllerProvider).valueOrNull;
      final storeName = profile?.fullName ?? 'Smart Ledger Store';

      // Send the email
      final success = await EmailService.sendPaymentReminder(
        customerName: customer.name,
        customerEmail: customer.email!,
        amount: amountOwed,
        note: _noteController.text.isEmpty
            ? 'Items purchased'
            : _noteController.text,
        date: DateFormat('dd MMM yyyy').format(_selectedDate),
        storeName: storeName,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction saved, but email failed to send.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email error: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingEmail = false);
      }
    }
  }
}
