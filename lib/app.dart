import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ledger/core/router/app_router.dart';
import 'package:smart_ledger/core/theme/app_theme.dart';
import 'package:smart_ledger/core/constants/app_constants.dart';

class SmartLedgerApp extends ConsumerWidget {
  const SmartLedgerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // TODO: Connect to settings provider
      routerConfig: appRouter,
    );
  }
}
