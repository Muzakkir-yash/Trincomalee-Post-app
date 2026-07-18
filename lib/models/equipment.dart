class Equipment {
  final String id;
  final String postOfficeId;
  final String name;
  final String category; // 'IT Equipment', 'Logistics', 'Office Furniture', 'Postal Tools'
  final int quantity;
  final String status; // 'Working', 'Maintenance', 'Damaged'

  Equipment({
    required this.id,
    required this.postOfficeId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.status,
  });

  Equipment copyWith({
    String? id,
    String? postOfficeId,
    String? name,
    String? category,
    int? quantity,
    String? status,
  }) {
    return Equipment(
      id: id ?? this.id,
      postOfficeId: postOfficeId ?? this.postOfficeId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
    );
  }

  factory Equipment.fromMap(String id, Map<String, dynamic> map) {
    return Equipment(
      id: id,
      postOfficeId: map['postOfficeId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      quantity: map['quantity'] ?? 0,
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postOfficeId': postOfficeId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'status': status,
    };
  }
}
