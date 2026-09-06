import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ledger/app.dart';
import 'package:smart_ledger/features/auth/presentation/auth_controller.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We override authStateProvider to avoid checking Supabase.instance which is not initialized in tests.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const SmartLedgerApp(),
      ),
    );

    // Wait for animations and routing to settle (e.g. redirect to login)
    await tester.pumpAndSettle();

    // Verify that the app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
