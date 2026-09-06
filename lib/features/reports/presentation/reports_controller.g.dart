// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportsControllerHash() => r'41d5abc063ff1b777ad19868a42dc792de79868c';

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

abstract class _$ReportsController
    extends BuildlessAutoDisposeAsyncNotifier<ReportState> {
  late final String period;

  FutureOr<ReportState> build(String period);
}

/// See also [ReportsController].
@ProviderFor(ReportsController)
const reportsControllerProvider = ReportsControllerFamily();

/// See also [ReportsController].
class ReportsControllerFamily extends Family<AsyncValue<ReportState>> {
  /// See also [ReportsController].
  const ReportsControllerFamily();

  /// See also [ReportsController].
  ReportsControllerProvider call(String period) {
    return ReportsControllerProvider(period);
  }

  @override
  ReportsControllerProvider getProviderOverride(
    covariant ReportsControllerProvider provider,
  ) {
    return call(provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reportsControllerProvider';
}

/// See also [ReportsController].
class ReportsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ReportsController, ReportState> {
  /// See also [ReportsController].
  ReportsControllerProvider(String period)
    : this._internal(
        () => ReportsController()..period = period,
        from: reportsControllerProvider,
        name: r'reportsControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reportsControllerHash,
        dependencies: ReportsControllerFamily._dependencies,
        allTransitiveDependencies:
            ReportsControllerFamily._allTransitiveDependencies,
        period: period,
      );

  ReportsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final String period;

  @override
  FutureOr<ReportState> runNotifierBuild(covariant ReportsController notifier) {
    return notifier.build(period);
  }

  @override
  Override overrideWith(ReportsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReportsControllerProvider._internal(
        () => create()..period = period,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ReportsController, ReportState>
  createElement() {
    return _ReportsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportsControllerProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReportsControllerRef on AutoDisposeAsyncNotifierProviderRef<ReportState> {
  /// The parameter `period` of this provider.
  String get period;
}

class _ReportsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<ReportsController, ReportState>
    with ReportsControllerRef {
  _ReportsControllerProviderElement(super.provider);

  @override
  String get period => (origin as ReportsControllerProvider).period;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
