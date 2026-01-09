class CustomerModel {
  final String id;
  final String ownerId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double totalGiven; // We gave (Receivable)
  final double totalReceived; // We got (Payable reduction)
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
    required this.createdAt,
  });

  // Derived for UI compatibility
  double get totalDue => totalGiven - totalReceived;
  bool get isReceivable => totalDue > 0;
  bool get isPayable => totalDue < 0;
  double get absBalance => totalDue.abs();

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
      'created_at': createdAt.toIso8601String(),
    };
  }
}
