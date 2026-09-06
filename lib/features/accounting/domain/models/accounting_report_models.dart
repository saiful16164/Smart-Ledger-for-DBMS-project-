import 'package:smart_ledger/features/accounting/domain/models/account_model.dart';

class LedgerRowModel {
  final DateTime date;
  final String voucherNo;
  final String particulars;
  final double debit;
  final double credit;
  final double balance;

  const LedgerRowModel({
    required this.date,
    required this.voucherNo,
    required this.particulars,
    required this.debit,
    required this.credit,
    required this.balance,
  });
}

class TrialBalanceRowModel {
  final AccountModel account;
  final double debit;
  final double credit;

  const TrialBalanceRowModel({
    required this.account,
    required this.debit,
    required this.credit,
  });
}

class TrialBalanceModel {
  final List<TrialBalanceRowModel> rows;

  const TrialBalanceModel(this.rows);

  double get totalDebit => rows.fold(0, (sum, row) => sum + row.debit);
  double get totalCredit => rows.fold(0, (sum, row) => sum + row.credit);
  double get difference => totalDebit - totalCredit;
  bool get isBalanced => difference.abs() < 0.01;
}
