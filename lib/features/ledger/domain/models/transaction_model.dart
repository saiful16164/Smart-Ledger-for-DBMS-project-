enum TransactionType {
  sale, // Customer owes money (Red for shop owner in ledger context if not careful, but usually Green "To Receive")
  payment, // Customer paid money (Green "Received")
  expense, // Business expense (Red)
  cashIn, // Owner added money (Green)
  cashOut, // Owner took money (Red)
}

class TransactionModel {
  final String? id;
  final String? customerId;
  final double amount;
  final TransactionType type;
  final String? category;
  final String? note;
  final DateTime date;

  TransactionModel({
    this.id,
    this.customerId,
    required this.amount,
    required this.type,
    this.category,
    this.note,
    required this.date,
  });

  // Factory for Sale (Customer Due)
  factory TransactionModel.sale({
    String? id,
    required String customerId,
    required double amount,
    String? note,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id,
      customerId: customerId,
      amount: amount,
      type: TransactionType.sale,
      note: note,
      date: date ?? DateTime.now(),
    );
  }

  // Factory for Payment (Customer Paid)
  factory TransactionModel.payment({
    String? id,
    required String customerId,
    required double amount,
    String? note,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id,
      customerId: customerId,
      amount: amount,
      type: TransactionType.payment,
      note: note,
      date: date ?? DateTime.now(),
    );
  }

  // Factory for Expense
  factory TransactionModel.expense({
    String? id,
    required double amount,
    required String category,
    String? note,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id,
      amount: amount,
      type: TransactionType.expense,
      category: category,
      note: note,
      date: date ?? DateTime.now(),
    );
  }

  bool get isIncome {
    return type == TransactionType.payment || type == TransactionType.cashIn;
  }
}
