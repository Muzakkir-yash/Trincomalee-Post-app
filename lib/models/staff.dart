class Staff {
  final String id;
  final String postOfficeId;
  final String name;
  final String designation;
  final String phone;
  final String appointmentDate; // Renamed from joinDate
  final String assumeDate; // Date of assume this office
  final String nic;
  final String dob; // Date of Birth
  final String paySheetNumber;
  final String? avatarUrl; // Optional image URL

  Staff({
    required this.id,
    required this.postOfficeId,
    required this.name,
    required this.designation,
    required this.phone,
    required this.appointmentDate,
    required this.assumeDate,
    required this.nic,
    required this.dob,
    required this.paySheetNumber,
    this.avatarUrl,
  });

  Staff copyWith({
    String? id,
    String? postOfficeId,
    String? name,
    String? designation,
    String? phone,
    String? appointmentDate,
    String? assumeDate,
    String? nic,
    String? dob,
    String? paySheetNumber,
    String? avatarUrl,
  }) {
    return Staff(
      id: id ?? this.id,
      postOfficeId: postOfficeId ?? this.postOfficeId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      assumeDate: assumeDate ?? this.assumeDate,
      nic: nic ?? this.nic,
      dob: dob ?? this.dob,
      paySheetNumber: paySheetNumber ?? this.paySheetNumber,
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
      appointmentDate: map['appointmentDate'] ?? map['joinDate'] ?? '',
      assumeDate: map['assumeDate'] ?? '',
      nic: map['nic'] ?? '',
      dob: map['dob'] ?? '',
      paySheetNumber: map['paySheetNumber'] ?? '',
      avatarUrl: map['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postOfficeId': postOfficeId,
      'name': name,
      'designation': designation,
      'phone': phone,
      'appointmentDate': appointmentDate,
      'assumeDate': assumeDate,
      'nic': nic,
      'dob': dob,
      'paySheetNumber': paySheetNumber,
      'avatarUrl': avatarUrl,
    };
  }
}
