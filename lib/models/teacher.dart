class Teacher {
  final String id;
  final String cnic;
  final String name;
  final String email;
  final bool emailVerified;
  final int semester;
  final DateTime createdAt;

  Teacher({
    required this.id,
    required this.cnic,
    required this.name,
    required this.email,
    this.emailVerified = false,
    required this.semester,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cnic': cnic,
      'name': name,
      'email': email,
      'emailVerified': emailVerified,
      'semester': semester,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Teacher.fromJson(Map<String, dynamic> json, String id) {
    return Teacher(
      id: id,
      cnic: json['cnic'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['emailVerified'] ?? false,
      semester: json['semester'] ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Teacher copyWith({
    String? id,
    String? cnic,
    String? name,
    String? email,
    bool? emailVerified,
    int? semester,
    DateTime? createdAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      cnic: cnic ?? this.cnic,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
