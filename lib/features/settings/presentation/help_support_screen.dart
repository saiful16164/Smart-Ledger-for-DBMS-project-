import 'package:flutter/material.dart';
import 'package:dbms_project/core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSupportItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@smartledger.com',
            onTap: () {},
          ),
          _buildSupportItem(
            context,
            icon: Icons.phone_outlined,
            title: 'Call Us',
            subtitle: '+880 1234 567890',
            onTap: () {},
          ),
          _buildSupportItem(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            subtitle: 'Available 9 AM - 6 PM',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            'How do I add a customer?',
            'Go to the Dashboard or Customer tab and click the "Add Customer" button.',
          ),
          _buildFaqItem(
            'How is data secured?',
            'We use industry-standard encryption to keep your data safe.',
          ),
          _buildFaqItem(
            'Can I export my data?',
            'Currently export feature is coming soon.',
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
