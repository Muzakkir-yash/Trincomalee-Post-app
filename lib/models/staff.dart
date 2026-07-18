class Staff {
  final String id;
  final String postOfficeId;
  final String name;
  final String designation;
  final String phone;
  final String email;
  final String joinDate;
  final String? avatarUrl; // Optional image URL

  Staff({
    required this.id,
    required this.postOfficeId,
    required this.name,
    required this.designation,
    required this.phone,
    required this.email,
    required this.joinDate,
    this.avatarUrl,
  });

  Staff copyWith({
    String? id,
    String? postOfficeId,
    String? name,
    String? designation,
    String? phone,
    String? email,
    String? joinDate,
    String? avatarUrl,
  }) {
    return Staff(
      id: id ?? this.id,
      postOfficeId: postOfficeId ?? this.postOfficeId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory Staff.fromMap(String id, Map<String, dynamic> map) {
    return Staff(
      id: id,
      postOfficeId: map['postOfficeId'] ?? '',
      name: map['name'] ?? '',
      designation: map['designation'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      joinDate: map['joinDate'] ?? '',
      avatarUrl: map['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postOfficeId': postOfficeId,
      'name': name,
      'designation': designation,
      'phone': phone,
      'email': email,
      'joinDate': joinDate,
      'avatarUrl': avatarUrl,
    };
  }
}
