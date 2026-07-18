class PostOffice {
  final String id;
  final String name;
  final String code;
  final String type; // 'Main' or 'Sub'
  final String address;
  final String phone;
  final String email;
  final double latitude;
  final double longitude;
  final String password;

  PostOffice({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.address,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.password,
  });

  // Factory methods for copyWith
  PostOffice copyWith({
    String? id,
    String? name,
    String? code,
    String? type,
    String? address,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    String? password,
  }) {
    return PostOffice(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      password: password ?? this.password,
    );
  }

  factory PostOffice.fromMap(String id, Map<String, dynamic> map) {
    return PostOffice(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      type: map['type'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'type': type,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'password': password,
    };
  }
}
