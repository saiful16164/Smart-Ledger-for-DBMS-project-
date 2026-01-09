// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionRepositoryHash() =>
    r'af0bf60ddc3fb447176b7ea7bbea43ff597d835f';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider =
    AutoDisposeProvider<SupabaseTransactionRepository>.internal(
      transactionRepository,
      name: r'transactionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionRepositoryRef =
    AutoDisposeProviderRef<SupabaseTransactionRepository>;
String _$transactionControllerHash() =>
    r'd83d163bbd06afbe34e9f8f208d7982db3b04d87';

/// See also [TransactionController].
@ProviderFor(TransactionController)
final transactionControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      TransactionController,
      List<TransactionModel>
    >.internal(
      TransactionController.new,
      name: r'transactionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TransactionController =
    AutoDisposeAsyncNotifier<List<TransactionModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
