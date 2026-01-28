class Student {
  final String id;
  final String rollNumber;
  final String email;
  final String? password;
  final bool emailVerified;

  Student({
    required this.id,
    required this.rollNumber,
    required this.email,
    this.password,
    this.emailVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rollNumber': rollNumber,
      'email': email,
      'password': password,
      'emailVerified': emailVerified,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json, String id) {
    return Student(
      id: id,
      rollNumber: json['rollNumber'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      emailVerified: json['emailVerified'] ?? false,
    );
  }

  Student copyWith({
    String? id,
    String? rollNumber,
    String? email,
    String? password,
    bool? emailVerified,
  }) {
    return Student(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
