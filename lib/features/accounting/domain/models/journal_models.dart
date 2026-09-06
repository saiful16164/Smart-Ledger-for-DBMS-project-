import 'package:smart_ledger/features/accounting/domain/models/account_model.dart';

class JournalLineModel {
  final String id;
  final String journalEntryId;
  final String accountId;
  final double debit;
  final double credit;
  final DateTime createdAt;
  final AccountModel? account;

  const JournalLineModel({
    required this.id,
    required this.journalEntryId,
    required this.accountId,
    required this.debit,
    required this.credit,
    required this.createdAt,
    this.account,
  });

  factory JournalLineModel.fromJson(Map<String, dynamic> json) {
    return JournalLineModel(
      id: json['id'] as String,
      journalEntryId: json['journal_entry_id'] as String,
      accountId: json['account_id'] as String,
      debit: (json['debit'] as num? ?? 0).toDouble(),
      credit: (json['credit'] as num? ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      account: json['accounts'] != null
          ? AccountModel.fromJson(json['accounts'] as Map<String, dynamic>)
          : null,
    );
  }
}

class JournalEntryModel {
  final String id;
  final String ownerId;
  final String voucherNo;
  final DateTime date;
  final String narration;
  final String sourceType;
  final String? sourceId;
  final DateTime createdAt;
  final List<JournalLineModel> lines;

  const JournalEntryModel({
    required this.id,
    required this.ownerId,
    required this.voucherNo,
    required this.date,
    required this.narration,
    required this.sourceType,
    this.sourceId,
    required this.createdAt,
    this.lines = const [],
  });

  factory JournalEntryModel.fromJson(
    Map<String, dynamic> json, {
    List<JournalLineModel> lines = const [],
  }) {
    return JournalEntryModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      voucherNo: json['voucher_no'] as String,
      date: DateTime.parse(json['date'] as String),
      narration: json['narration'] as String? ?? '',
      sourceType: json['source_type'] as String? ?? 'manual',
      sourceId: json['source_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lines: lines,
    );
  }
}

class NewJournalLine {
  final String accountId;
  final double debit;
  final double credit;

  const NewJournalLine({
    required this.accountId,
    this.debit = 0,
    this.credit = 0,
  });
}
