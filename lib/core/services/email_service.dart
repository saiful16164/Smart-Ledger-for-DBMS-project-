import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for sending emails via EmailJS
class EmailService {
  static const String _serviceId = 'service_hngtkzs';
  static const String _templateId = 'template_21pdvu9';
  static const String _publicKey = 'SkbB7uEAP9CWKf0t8';
  static const String _emailJsUrl =
      'https://api.emailjs.com/api/v1.0/email/send';

  /// Sends a payment reminder email to the customer
  ///
  /// Returns true if successful, false otherwise
  static Future<bool> sendPaymentReminder({
    required String customerName,
    required String customerEmail,
    required double amount,
    required String note,
    required String date,
    required String storeName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_emailJsUrl),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost', // Required for EmailJS
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'customer_name': customerName,
            'to_email': customerEmail,
            'amount': amount.toStringAsFixed(2),
            'note': note.isNotEmpty ? note : 'Transaction',
            'date': date,
            'store_name': storeName,
          },
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('EmailJS Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('EmailJS Exception: $e');
      return false;
    }
  }
}
