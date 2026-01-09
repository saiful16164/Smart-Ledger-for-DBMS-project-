// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerTransactionsHash() =>
    r'f5750568dbe3faa959f85de12029eb7abdd0f88a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [customerTransactions].
@ProviderFor(customerTransactions)
const customerTransactionsProvider = CustomerTransactionsFamily();

/// See also [customerTransactions].
class CustomerTransactionsFamily
    extends Family<AsyncValue<List<TransactionModel>>> {
  /// See also [customerTransactions].
  const CustomerTransactionsFamily();

  /// See also [customerTransactions].
  CustomerTransactionsProvider call(String customerId) {
    return CustomerTransactionsProvider(customerId);
  }

  @override
  CustomerTransactionsProvider getProviderOverride(
    covariant CustomerTransactionsProvider provider,
  ) {
    return call(provider.customerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customerTransactionsProvider';
}

/// See also [customerTransactions].
class CustomerTransactionsProvider
    extends AutoDisposeFutureProvider<List<TransactionModel>> {
  /// See also [customerTransactions].
  CustomerTransactionsProvider(String customerId)
    : this._internal(
        (ref) =>
            customerTransactions(ref as CustomerTransactionsRef, customerId),
        from: customerTransactionsProvider,
        name: r'customerTransactionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerTransactionsHash,
        dependencies: CustomerTransactionsFamily._dependencies,
        allTransitiveDependencies:
            CustomerTransactionsFamily._allTransitiveDependencies,
        customerId: customerId,
      );

  CustomerTransactionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
  }) : super.internal();

  final String customerId;

  @override
  Override overrideWith(
    FutureOr<List<TransactionModel>> Function(CustomerTransactionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerTransactionsProvider._internal(
        (ref) => create(ref as CustomerTransactionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TransactionModel>> createElement() {
    return _CustomerTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerTransactionsProvider &&
        other.customerId == customerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomerTransactionsRef
    on AutoDisposeFutureProviderRef<List<TransactionModel>> {
  /// The parameter `customerId` of this provider.
  String get customerId;
}

class _CustomerTransactionsProviderElement
    extends AutoDisposeFutureProviderElement<List<TransactionModel>>
    with CustomerTransactionsRef {
  _CustomerTransactionsProviderElement(super.provider);

  @override
  String get customerId => (origin as CustomerTransactionsProvider).customerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
