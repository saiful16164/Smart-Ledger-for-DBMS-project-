enum PartyType { customer, supplier }

extension PartyTypeX on PartyType {
  String get value => switch (this) {
    PartyType.customer => 'customer',
    PartyType.supplier => 'supplier',
  };

  String get label => switch (this) {
    PartyType.customer => 'Customer',
    PartyType.supplier => 'Supplier',
  };

  static PartyType fromValue(String? value) {
    return value == 'supplier' ? PartyType.supplier : PartyType.customer;
  }
}

class CustomerModel {
  final String id;
  final String ownerId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double totalGiven; // We gave (Receivable)
  final double totalReceived; // We got / paid depending on party type
  final PartyType partyType;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.totalGiven = 0.0,
    this.totalReceived = 0.0,
    this.partyType = PartyType.customer,
    required this.createdAt,
  });

  // Derived for UI compatibility
  double get totalDue => totalGiven - totalReceived;
  bool get isCustomer => partyType == PartyType.customer;
  bool get isSupplier => partyType == PartyType.supplier;
  bool get isReceivable => totalDue > 0;
  bool get isPayable => totalDue < 0;
  double get absBalance => totalDue.abs();

  String get balanceLabel {
    if (totalDue == 0) return 'Settled';
    if (isCustomer) {
      return isReceivable ? 'You\'ll Get' : 'You\'ll Give';
    }
    return isPayable ? 'You Paid' : 'Supplier Owes';
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      totalGiven: (json['total_given'] as num?)?.toDouble() ?? 0.0,
      totalReceived: (json['total_received'] as num?)?.toDouble() ?? 0.0,
      partyType: PartyTypeX.fromValue(json['party_type'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'total_given': totalGiven,
      'total_received': totalReceived,
      'party_type': partyType.value,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
