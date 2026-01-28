class Subject {
  final String id;
  final String name;

  Subject({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  factory Subject.fromJson(Map<String, dynamic> json, String id) {
    return Subject(id: id, name: json['name'] ?? '');
  }
}
