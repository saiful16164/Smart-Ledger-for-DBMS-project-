enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String ownerId;
  final double amount;
  final TransactionType type;
  final String? customerId;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  // Optional: Joined Customer Name if fetched with join
  final String? customerName;

  TransactionModel({
    required this.id,
    required this.ownerId,
    required this.amount,
    required this.type,
    this.customerId,
    this.note,
    required this.date,
    required this.createdAt,
    this.customerName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: (json['type'] as String) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      customerId: json['customer_id'] as String?,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      // Check if customers relationship is expanded, e.g. select('*, customers(name)')
      customerName: json['customers'] != null
          ? (json['customers'] as Map<String, dynamic>)['name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'customer_id': customerId,
      'note': note,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
