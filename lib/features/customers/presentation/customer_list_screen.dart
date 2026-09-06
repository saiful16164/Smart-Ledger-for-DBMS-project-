import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ledger/core/theme/app_colors.dart';
import 'package:smart_ledger/features/customers/domain/models/customer_model.dart';
import 'package:smart_ledger/features/customers/presentation/widgets/customer_card.dart';
import 'package:smart_ledger/features/customers/presentation/widgets/add_customer_sheet.dart';
import 'package:smart_ledger/features/customers/presentation/customer_controller.dart';
import 'package:go_router/go_router.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'All'; // All, Customers, Suppliers, To Receive, To Pay

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerModel> _filterCustomers(List<CustomerModel> customers) {
    return customers.where((customer) {
      // 1. Search Filter
      final matchesSearch =
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (customer.phone?.contains(_searchQuery) ?? false) ||
          (customer.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);

      if (!matchesSearch) return false;

      // 2. Type Filter
      if (_filterType == 'Customers') {
        return customer.isCustomer;
      } else if (_filterType == 'Suppliers') {
        return customer.isSupplier;
      } else if (_filterType == 'To Receive') {
        return customer.totalDue > 0;
      } else if (_filterType == 'To Pay') {
        return customer.totalDue < 0;
      }

      return true; // All
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers & Suppliers'),
        centerTitle: false,
      ),

      body: Column(
        children: [
          // Search & Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Customers'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Suppliers'),
                      const SizedBox(width: 8),
                      _buildFilterChip('To Receive'),
                      const SizedBox(width: 8),
                      _buildFilterChip('To Pay'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List Content
          Expanded(
            child: customersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allCustomers) {
                final filteredCustomers = _filterCustomers(allCustomers);

                if (filteredCustomers.isEmpty) {
                  return Center(
                    child: Text(
                      _filterType == 'Suppliers'
                          ? 'No suppliers found.'
                          : 'No customers or suppliers found.',
                    ),
                  );
                }

                // Calculate Totals based on filtered list? Or all? Usually filtered.
                final totalDue = filteredCustomers
                    .map((c) => c.totalDue)
                    .fold(0.0, (previous, current) => previous + current);

                return Column(
                  children: [
                    // Summary Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: colorScheme.primary.withOpacity(0.08),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filtered: ${filteredCustomers.length}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Net Due: ৳${totalDue.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: totalDue >= 0
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return CustomerCard(
                            customer: customer,
                            onTap: () {
                              context.push(
                                '/customers/${customer.id}',
                                extra: customer,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddCustomerSheet(),
          );
        },
        label: const Text('Add Party'),

        icon: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterType == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _filterType = label;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
