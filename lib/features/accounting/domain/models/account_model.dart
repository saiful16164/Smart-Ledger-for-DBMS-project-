enum AccountType { asset, liability, equity, income, expense }

extension AccountTypeX on AccountType {
  String get value => switch (this) {
    AccountType.asset => 'asset',
    AccountType.liability => 'liability',
    AccountType.equity => 'equity',
    AccountType.income => 'income',
    AccountType.expense => 'expense',
  };

  String get label => switch (this) {
    AccountType.asset => 'Assets',
    AccountType.liability => 'Liabilities',
    AccountType.equity => 'Equity',
    AccountType.income => 'Income',
    AccountType.expense => 'Expenses',
  };

  bool get hasDebitNormalBalance =>
      this == AccountType.asset || this == AccountType.expense;

  static AccountType fromValue(String value) {
    return AccountType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AccountType.asset,
    );
  }
}

class AccountModel {
  final String id;
  final String ownerId;
  final String code;
  final String name;
  final AccountType type;
  final bool isSystem;
  final DateTime createdAt;

  const AccountModel({
    required this.id,
    required this.ownerId,
    required this.code,
    required this.name,
    required this.type,
    required this.isSystem,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      type: AccountTypeX.fromValue(json['type'] as String),
      isSystem: json['is_system'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
