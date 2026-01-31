import 'package:dbms_project/core/constants/supabase_constants.dart';
import 'package:dbms_project/features/customers/domain/models/customer_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCustomerRepository {
  final SupabaseClient _supabase;

  SupabaseCustomerRepository(this._supabase);

  Future<List<CustomerModel>> getCustomers() async {
    final data = await _supabase
        .from(SupabaseConstants.tableCustomers)
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<CustomerModel> getCustomer(String id) async {
    final data = await _supabase
        .from(SupabaseConstants.tableCustomers)
        .select()
        .eq('id', id)
        .single();

    return CustomerModel.fromJson(data);
  }

  Future<CustomerModel> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final data = await _supabase
        .from(SupabaseConstants.tableCustomers)
        .insert({
          'owner_id': user.id,
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'total_given': 0,
          'total_received': 0,
        })
        .select()
        .single();

    return CustomerModel.fromJson(data);
  }

  Future<CustomerModel> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final data = await _supabase
        .from(SupabaseConstants.tableCustomers)
        .update({
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
        })
        .eq('id', id)
        .select()
        .single();

    return CustomerModel.fromJson(data);
  }

  Future<void> updateBalance({
    required String customerId,
    required double amount,
    required bool
    isGiven, // true = we gave (expense/credit), false = we received (income/payment)
  }) async {
    final customer = await getCustomer(customerId);

    if (isGiven) {
      await _supabase
          .from(SupabaseConstants.tableCustomers)
          .update({'total_given': customer.totalGiven + amount})
          .eq('id', customerId);
    } else {
      await _supabase
          .from(SupabaseConstants.tableCustomers)
          .update({'total_received': customer.totalReceived + amount})
          .eq('id', customerId);
    }
  }

  Future<void> deleteCustomer(String id) async {
    await _supabase
        .from(SupabaseConstants.tableCustomers)
        .delete()
        .eq('id', id);
  }
}
