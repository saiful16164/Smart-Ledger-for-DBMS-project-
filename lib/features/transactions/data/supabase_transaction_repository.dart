import 'package:dbms_project/core/constants/supabase_constants.dart';
import 'package:dbms_project/features/transactions/domain/models/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTransactionRepository {
  final SupabaseClient _supabase;

  SupabaseTransactionRepository(this._supabase);

  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    // We select *, and also join with customers to get the name
    // Syntax: select('*, customers(name)')
    final data = await _supabase
        .from(SupabaseConstants.tableTransactions)
        .select('*, ${SupabaseConstants.tableCustomers}(name)')
        .order('date', ascending: false)
        .limit(limit);

    return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByCustomer(
    String customerId,
  ) async {
    final data = await _supabase
        .from(SupabaseConstants.tableTransactions)
        .select()
        .eq('customer_id', customerId)
        .order('date', ascending: false);

    return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<TransactionModel> addTransaction({
    required double amount,
    required TransactionType type,
    String? customerId,
    String? note,
    required DateTime date,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final data = await _supabase
        .from(SupabaseConstants.tableTransactions)
        .insert({
          'owner_id': user.id,
          'amount': amount,
          'type': type == TransactionType.income ? 'income' : 'expense',
          'customer_id': customerId,
          'note': note,
          'date': date.toIso8601String(),
        })
        .select()
        .single();

    return TransactionModel.fromJson(data);
  }

  Future<double> getDailyIncome(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final data = await _supabase
        .from(SupabaseConstants.tableTransactions)
        .select('amount')
        .eq('type', 'income')
        .gte('date', startOfDay.toIso8601String())
        .lt('date', endOfDay.toIso8601String());

    final List<dynamic> rows = data as List<dynamic>;
    if (rows.isEmpty) return 0.0;
    return rows.fold<double>(
      0.0,
      (double sum, dynamic row) => sum + (row['amount'] as num).toDouble(),
    );
  }

  Future<double> getCashInHand() async {
    // Fetching all amounts. Optimize this with RPC or View in production.
    final data = await _supabase
        .from(SupabaseConstants.tableTransactions)
        .select('amount, type');

    final List<dynamic> rows = data as List<dynamic>;
    double balance = 0.0;
    for (var row in rows) {
      final amount = (row['amount'] as num).toDouble();
      final type = row['type'] as String;
      if (type == 'income') {
        balance += amount;
      } else {
        balance -= amount;
      }
    }
    return balance;
  }

  Future<List<TransactionModel>> getAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    // 1. Start query construction
    var query = _supabase
        .from(SupabaseConstants.tableTransactions)
        .select(
          '*, ${SupabaseConstants.tableCustomers}(name)',
        ); // Returns PostgrestFilterBuilder

    // 2. Apply filters (still returns PostgrestFilterBuilder)
    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String());
    }
    if (type != null) {
      query = query.eq(
        'type',
        type == TransactionType.income ? 'income' : 'expense',
      );
    }

    // 3. Apply order (returns PostgrestTransformBuilder) and await
    final data = await query.order('date', ascending: false);

    return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<Map<String, double>> getReportSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final data = await _supabase
        .from(SupabaseConstants.tableTransactions)
        .select('amount, type')
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String());

    final List<dynamic> rows = data as List<dynamic>;
    double income = 0;
    double expense = 0;

    for (var row in rows) {
      final amount = (row['amount'] as num).toDouble();
      final type = row['type'] as String;
      if (type == 'income') {
        income += amount;
      } else {
        expense += amount;
      }
    }

    return {'income': income, 'expense': expense, 'profit': income - expense};
  }
}
