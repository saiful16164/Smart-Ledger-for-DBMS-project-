import 'package:flutter/material.dart';
import 'package:dbms_project/core/theme/app_colors.dart';
import 'package:dbms_project/features/customers/domain/models/customer_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;

  const CustomerCard({super.key, required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with Initials
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  customer.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name & Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone ?? 'No Phone',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${customer.absBalance.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: customer.isReceivable
                          ? AppColors.success
                          : (customer.isPayable
                                ? AppColors.error
                                : AppColors.textSecondaryLight),
                    ),
                  ),
                  if (customer.totalDue != 0)
                    Row(
                      children: [
                        Text(
                          customer.isReceivable
                              ? 'You\'ll Get'
                              : 'You\'ll Give',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: customer.isReceivable
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          customer.isReceivable
                              ? Icons.arrow_back
                              : Icons.arrow_forward,
                          size: 12,
                          color: customer.isReceivable
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
