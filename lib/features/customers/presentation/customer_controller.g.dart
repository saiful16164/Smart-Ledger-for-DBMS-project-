// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerRepositoryHash() =>
    r'b8ee0d2dca71975db7d1c5a7f6b0bbccb1fadb1d';

/// See also [customerRepository].
@ProviderFor(customerRepository)
final customerRepositoryProvider =
    AutoDisposeProvider<SupabaseCustomerRepository>.internal(
      customerRepository,
      name: r'customerRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerRepositoryRef =
    AutoDisposeProviderRef<SupabaseCustomerRepository>;
String _$customerControllerHash() =>
    r'85ac744d4079307fec70b937b160c0107a131455';

/// See also [CustomerController].
@ProviderFor(CustomerController)
final customerControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      CustomerController,
      List<CustomerModel>
    >.internal(
      CustomerController.new,
      name: r'customerControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CustomerController = AutoDisposeAsyncNotifier<List<CustomerModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
