

import 'package:smart_ledger/features/customers/data/supabase_customer_repository.dart';
import 'package:smart_ledger/features/customers/domain/models/customer_model.dart';
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
    PartyType partyType = PartyType.customer,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(customerRepositoryProvider)
          .addCustomer(
            name: name,
            phone: phone,
            email: email,
            address: address,
            partyType: partyType,
          );
      state = AsyncData(
        await ref.refresh(customerRepositoryProvider).getCustomers(),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
    PartyType? partyType,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(customerRepositoryProvider)
          .updateCustomer(
            id: id,
            name: name,
            phone: phone,
            email: email,
            address: address,
            partyType: partyType,
          );
      state = AsyncData(
        await ref.refresh(customerRepositoryProvider).getCustomers(),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> deleteCustomer(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(customerRepositoryProvider).deleteCustomer(id);
      state = AsyncData(
        await ref.refresh(customerRepositoryProvider).getCustomers(),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
