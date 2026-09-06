import 'package:smart_ledger/features/transactions/domain/models/transaction_model.dart';
import 'package:smart_ledger/features/transactions/presentation/transaction_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'customer_detail_controller.g.dart';

@riverpod
Future<List<TransactionModel>> customerTransactions(
  CustomerTransactionsRef ref,
  String customerId,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionsByCustomer(customerId);
}
