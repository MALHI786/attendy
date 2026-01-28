import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';
import '../services/email_service.dart';
import '../models/student.dart';
import '../models/subject.dart';

class AttendanceEmailService {
  final FirebaseService _firebaseService = FirebaseService();
  final EmailService _emailService = EmailService();

  /// Send email notifications to students with attendance below 75%
  Future<Map<String, dynamic>> sendLowAttendanceNotifications(String crRollNumber) async {
    try {
      debugPrint('📧 Starting email notification process for CR: $crRollNumber');

      // Get all students
      final students = await _firebaseService.getStudents(crRollNumber);
      if (students.isEmpty) {
        return {
          'success': false,
          'message': 'No students found',
          'emailsSent': 0,
        };
      }

      // Get all subjects
      final subjects = await _firebaseService.getSubjects(crRollNumber);
      if (subjects.isEmpty) {
        return {
          'success': false,
          'message': 'No subjects found',
          'emailsSent': 0,
        };
      }

      int emailsSent = 0;
      int emailsFailed = 0;
      List<String> failedStudents = [];

      // Process each subject
      for (final subject in subjects) {
        debugPrint('📊 Processing subject: ${subject.name}');

        // Get attendance records for this subject
        final attendanceRecords = await _firebaseService.getAttendanceHistory(
          crRollNumber,
          subject.id,
        );

        if (attendanceRecords.isEmpty) {
          debugPrint('⚠️ No attendance records found for ${subject.name}');
          continue;
        }

        // Calculate attendance percentage for each student
        final Map<String, int> presentCount = {};
        final Map<String, int> totalCount = {};

        for (final record in attendanceRecords) {
          final studentsData = record['students'];
          if (studentsData == null) continue;
          
          // Safely convert to Map<String, dynamic>
          final attendance = Map<String, dynamic>.from(studentsData as Map);

          for (final entry in attendance.entries) {
            final studentId = entry.key;
            final isPresent = entry.value == true;

            totalCount[studentId] = (totalCount[studentId] ?? 0) + 1;
            if (isPresent) {
              presentCount[studentId] = (presentCount[studentId] ?? 0) + 1;
            }
          }
        }

        // Find students with < 75% attendance
        for (final student in students) {
          final total = totalCount[student.id] ?? 0;
          if (total == 0) continue; // Skip if no attendance marked

          final present = presentCount[student.id] ?? 0;
          final percentage = (present / total) * 100;

          if (percentage < 75.0) {
            debugPrint(
              '⚠️ Low attendance: ${student.rollNumber} - $percentage% in ${subject.name}',
            );

            // Send email notification
            try {
              await _emailService.sendLowAttendanceAlert(
                studentEmail: student.email,
                studentName: student.rollNumber, // Using rollNumber as name
                subjectName: subject.name,
                attendancePercentage: percentage.toStringAsFixed(1),
                presentDays: present,
                totalDays: total,
                absentDays: total - present,
              );
              emailsSent++;
              debugPrint('✅ Email sent to ${student.rollNumber}');
            } catch (e) {
              debugPrint('❌ Failed to send email to ${student.rollNumber}: $e');
              emailsFailed++;
              failedStudents.add(student.rollNumber);
            }
          }
        }
      }

      debugPrint('📧 Email notifications complete: $emailsSent sent, $emailsFailed failed');

      return {
        'success': true,
        'message': emailsFailed == 0
            ? '$emailsSent email(s) sent successfully'
            : '$emailsSent email(s) sent, $emailsFailed failed',
        'emailsSent': emailsSent,
        'emailsFailed': emailsFailed,
        'failedStudents': failedStudents,
      };
    } catch (e) {
      debugPrint('❌ Error in sendLowAttendanceNotifications: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'emailsSent': 0,
      };
    }
  }
}
