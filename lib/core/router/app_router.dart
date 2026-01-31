import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dbms_project/core/widgets/app_scaffold.dart';
import 'package:dbms_project/features/dashboard/presentation/dashboard_screen.dart';
// Placeholder imports for other screens
import 'package:dbms_project/features/customers/presentation/customer_list_screen.dart';
import 'package:dbms_project/features/cashbook/presentation/cashbook_screen.dart';
import 'package:dbms_project/features/reports/presentation/reports_screen.dart';
import 'package:dbms_project/features/settings/presentation/settings_screen.dart';
import 'package:dbms_project/features/transactions/presentation/add_transaction_screen.dart';
import 'package:dbms_project/features/customers/presentation/customer_detail_screen.dart';
import 'package:dbms_project/features/customers/domain/models/customer_model.dart';
import 'package:dbms_project/features/settings/presentation/help_support_screen.dart';
import 'package:dbms_project/features/settings/presentation/privacy_policy_screen.dart';
import 'package:dbms_project/features/auth/presentation/login_screen.dart';
import 'package:dbms_project/features/auth/presentation/signup_screen.dart';
import 'package:dbms_project/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      ref
          .read(authStateProvider.stream)
          .distinct((previous, next) => previous?.id == next?.id),
    ),
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomerListScreen(),
          ),
          GoRoute(
            path: '/cashbook',
            builder: (context, state) => const CashbookScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final customerId = extra?['customerId'] as String?;
          return AddTransactionScreen(initialCustomerId: customerId);
        },
      ),
      GoRoute(
        path: '/customers/:customerId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final customer = state.extra as CustomerModel;
          return CustomerDetailScreen(customer: customer);
        },
      ),
      GoRoute(
        path: '/help-support',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
