import 'package:dbms_project/core/constants/supabase_constants.dart';
import 'package:dbms_project/features/customers/data/supabase_customer_repository.dart';
import 'package:dbms_project/features/customers/domain/models/customer_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'customer_controller.g.dart';

@riverpod
SupabaseCustomerRepository customerRepository(CustomerRepositoryRef ref) {
  return SupabaseCustomerRepository(Supabase.instance.client);
}

@riverpod
class CustomerController extends _$CustomerController {
  @override
  FutureOr<List<CustomerModel>> build() {
    return ref.watch(customerRepositoryProvider).getCustomers();
  }

  Future<void> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(customerRepositoryProvider)
          .addCustomer(
            name: name,
            phone: phone,
            email: email,
            address: address,
          );
      return ref.refresh(customerRepositoryProvider).getCustomers();
    });
  }

  Future<void> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(customerRepositoryProvider)
          .updateCustomer(
            id: id,
            name: name,
            phone: phone,
            email: email,
            address: address,
          );
      return ref.refresh(customerRepositoryProvider).getCustomers();
    });
  }

  Future<void> deleteCustomer(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(customerRepositoryProvider).deleteCustomer(id);
      return ref.refresh(customerRepositoryProvider).getCustomers();
    });
  }
}
