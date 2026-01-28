class AttendanceRecord {
  final String studentId;
  final String subjectId;
  final DateTime date;
  final bool isPresent;

  AttendanceRecord({
    required this.studentId,
    required this.subjectId,
    required this.date,
    required this.isPresent,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'subjectId': subjectId,
      'date': date.toIso8601String(),
      'isPresent': isPresent,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentId: json['studentId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      date: DateTime.parse(json['date']),
      isPresent: json['isPresent'] ?? false,
    );
  }
}
