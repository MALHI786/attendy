import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/subject.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Get ID from identifier (sanitized for Firebase key)
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[.\#\$\[\]\/]'), '_');
  }

  // Get CR ID from roll number (sanitized for Firebase key)
  String _getCrId(String rollNumber) {
    return rollNumber.replaceAll('-', '_');
  }

  // ==================== USER TYPE MANAGEMENT ====================

  Future<void> setUserType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', type);
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  // ==================== TEACHER AUTHENTICATION ====================

  Future<bool> isTeacherRegistered(String cnic) async {
    try {
      final teacherId = _sanitizeKey(cnic);
      print('🔍 Checking registration for Teacher CNIC: $teacherId');
      final snapshot = await _database.child('teachers/$teacherId/password').get();
      print('📦 Snapshot exists: ${snapshot.exists}');
      return snapshot.exists;
    } catch (e, stackTrace) {
      print('❌ Error checking Teacher registration: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> registerTeacher(
    String cnic,
    String name,
    String email,
    String password,
    int semester,
  ) async {
    try {
      final teacherId = _sanitizeKey(cnic);
      print('💾 Registering Teacher: $teacherId with semester: $semester');

      // Create Firebase Authentication user with email
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Firebase Auth user created: ${userCredential.user?.uid}');

      // Save teacher data to Realtime Database
      await _database.child('teachers/$teacherId').set({
        'cnic': cnic,
        'name': name,
        'email': email,
        'password': _hashPassword(password),
        'emailVerified': false,
        'semester': semester,
        'firebaseUid': userCredential.user?.uid,
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('✅ Teacher data saved to Firebase');

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teacherCnic', cnic);
      await prefs.setString('userType', 'teacher');
      await prefs.setInt('semester', semester);
      print('✅ Teacher data saved to local storage');
    } catch (e, stackTrace) {
      print('❌ Error registering Teacher: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Register teacher using Google Sign-In
  Future<void> registerTeacherWithGoogle(
    String cnic,
    String name,
    String email,
    int semester,
    String firebaseUid, {
    String? password,
  }) async {
    try {
      final teacherId = _sanitizeKey(cnic);
      print('💾 Registering Teacher with Google: $teacherId');

      // Save teacher data to Realtime Database
      await _database.child('teachers/$teacherId').set({
        'cnic': cnic,
        'name': name,
        'email': email,
        'password': password ?? '', // Password set during Google registration
        'emailVerified': true, // Google emails are already verified
        'semester': semester,
        'firebaseUid': firebaseUid,
        'authProvider': 'google',
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('✅ Teacher data saved to Firebase');

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teacherCnic', cnic);
      await prefs.setString('userType', 'teacher');
      await prefs.setInt('semester', semester);
      print('✅ Teacher data saved to local storage');
    } catch (e, stackTrace) {
      print('❌ Error registering Teacher with Google: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> loginTeacher(String cnic, String password, String? email) async {
    try {
      final teacherId = _sanitizeKey(cnic);
      print('🔑 Logging in Teacher: $teacherId');

      // If no email provided, user is not registered
      if (email == null) {
        print('❌ Teacher not registered');
        return false;
      }

      // Sign in with Firebase Authentication
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Firebase Auth sign-in successful: ${userCredential.user?.uid}');
      } catch (authError) {
        print('❌ Firebase Auth error: $authError');
        // If auth fails, fallback to database password check
        final snapshot = await _database.child('teachers/$teacherId/password').get();
        if (!snapshot.exists || snapshot.value != _hashPassword(password)) {
          print('❌ Password does not match');
          return false;
        }
        print('✅ Password matches (fallback check)');
      }

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teacherCnic', cnic);
      await prefs.setString('userType', 'teacher');

      // Get semester
      final semesterSnapshot = await _database.child('teachers/$teacherId/semester').get();
      if (semesterSnapshot.exists) {
        await prefs.setInt('semester', semesterSnapshot.value as int);
        print('✅ Semester saved: ${semesterSnapshot.value}');
      }

      return true;
    } catch (e, stackTrace) {
      print('❌ Error logging in Teacher: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String?> getTeacherEmail(String cnic) async {
    try {
      final teacherId = _sanitizeKey(cnic);
      final snapshot = await _database.child('teachers/$teacherId/email').get();
      if (snapshot.exists) {
        return snapshot.value as String;
      }
      return null;
    } catch (e) {
      print('❌ Error getting teacher email: $e');
      return null;
    }
  }

  Future<void> updateTeacherEmailVerified(String cnic, bool verified) async {
    final teacherId = _sanitizeKey(cnic);
    await _database.child('teachers/$teacherId/emailVerified').set(verified);
  }

  Future<String?> getLoggedInTeacher() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('teacherCnic');
  }

  Future<void> logoutTeacher() async {
    await _auth.signOut(); // Sign out from Firebase Auth
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('teacherCnic');
    await prefs.remove('userType');
    await prefs.remove('semester');
  }

  // ==================== CR (STUDENT) AUTHENTICATION ====================

  Future<bool> isCrRegistered(String rollNumber) async {
    try {
      final crId = _getCrId(rollNumber);
      print('🔍 Checking registration for CR ID: $crId');
      final snapshot = await _database.child('crs/$crId/password').get();
      print('📦 Snapshot exists: ${snapshot.exists}');
      return snapshot.exists;
    } catch (e, stackTrace) {
      print('❌ Error checking CR registration: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> registerCr(
    String rollNumber,
    String password,
    String email,
    int semester,
  ) async {
    try {
      final crId = _getCrId(rollNumber);
      print('💾 Registering CR: $crId with semester: $semester');

      // Create Firebase Authentication user with email
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Firebase Auth user created: ${userCredential.user?.uid}');

      // Save CR data to Realtime Database
      await _database.child('crs/$crId').set({
        'rollNumber': rollNumber,
        'password': _hashPassword(password),
        'email': email,
        'emailVerified': false,
        'semester': semester,
        'firebaseUid': userCredential.user?.uid,
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('✅ CR data saved to Firebase');

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('crRollNumber', rollNumber);
      await prefs.setString('userType', 'student');
      await prefs.setInt('semester', semester);
      print('✅ CR data saved to local storage');
    } catch (e, stackTrace) {
      print('❌ Error registering CR: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Register CR (student) using Google Sign-In
  Future<void> registerCrWithGoogle(
    String rollNumber,
    String email,
    int semester,
    String firebaseUid, {
    String? password,
  }) async {
    try {
      final crId = _getCrId(rollNumber);
      print('💾 Registering CR with Google: $crId');

      // Save CR data to Realtime Database
      await _database.child('crs/$crId').set({
        'rollNumber': rollNumber,
        'password': password ?? '', // Password set during Google registration
        'email': email,
        'emailVerified': true, // Google emails are already verified
        'semester': semester,
        'firebaseUid': firebaseUid,
        'authProvider': 'google',
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('✅ CR data saved to Firebase');

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('crRollNumber', rollNumber);
      await prefs.setString('userType', 'student');
      await prefs.setInt('semester', semester);
      print('✅ CR data saved to local storage');
    } catch (e, stackTrace) {
      print('❌ Error registering CR with Google: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Check if CR exists (returns email if found, null if not)
  Future<String?> getCrEmail(String rollNumber) async {
    try {
      final crId = _getCrId(rollNumber);
      final emailSnapshot = await _database.child('crs/$crId/email').get();
      if (emailSnapshot.exists) {
        return emailSnapshot.value as String;
      }
      return null;
    } catch (e) {
      print('❌ Error getting CR email: $e');
      return null;
    }
  }

  Future<bool> loginCr(String rollNumber, String password, String? email) async {
    try {
      final crId = _getCrId(rollNumber);
      print('🔑 Logging in CR: $crId');

      // If no email provided, user is not registered
      if (email == null) {
        print('❌ CR not registered');
        return false;
      }

      // Sign in with Firebase Authentication
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Firebase Auth sign-in successful: ${userCredential.user?.uid}');
      } catch (authError) {
        print('❌ Firebase Auth error: $authError');
        // If auth fails, fallback to database password check
        final snapshot = await _database.child('crs/$crId/password').get();
        if (!snapshot.exists) {
          print('❌ Password not found in database');
          return false;
        }

        final storedPassword = snapshot.value as String;
        final hashedInput = _hashPassword(password);
        
        // Check both hashed and plain text (for backward compatibility)
        if (storedPassword != hashedInput && storedPassword != password) {
          print('❌ Password does not match');
          return false;
        }
        print('✅ Password matches (fallback check)');
      }

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('crRollNumber', rollNumber);
      await prefs.setString('userType', 'student');

      // Get semester
      final semesterSnapshot = await _database.child('crs/$crId/semester').get();
      if (semesterSnapshot.exists) {
        await prefs.setInt('semester', semesterSnapshot.value as int);
        print('✅ Semester saved: ${semesterSnapshot.value}');
      }

      return true;
    } catch (e, stackTrace) {
      print('❌ Error logging in CR: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateCrEmailVerified(String rollNumber, bool verified) async {
    final crId = _getCrId(rollNumber);
    await _database.child('crs/$crId/emailVerified').set(verified);
  }

  Future<void> logoutCr() async {
    await _auth.signOut(); // Sign out from Firebase Auth
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('crRollNumber');
    await prefs.remove('userType');
    await prefs.remove('semester');
  }

  Future<String?> getLoggedInCr() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('crRollNumber');
  }

  Future<int?> getSemester() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('semester');
  }

  // ==================== SEMESTER MANAGEMENT ====================

  Future<void> updateSemester(String identifier, int semester, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('semester', semester);

    if (userType == 'teacher') {
      final teacherId = _sanitizeKey(identifier);
      await _database.child('teachers/$teacherId/semester').set(semester);
    } else {
      final crId = _getCrId(identifier);
      await _database.child('crs/$crId/semester').set(semester);
    }
  }

  // ==================== PASSWORD RESET ====================

  Future<void> storeVerificationCode(String email, String code) async {
    final emailKey = _sanitizeKey(email);
    await _database.child('verificationCodes/$emailKey').set({
      'code': code,
      'createdAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
    });
  }

  Future<bool> verifyCode(String email, String code) async {
    final emailKey = _sanitizeKey(email);
    final snapshot = await _database.child('verificationCodes/$emailKey').get();
    
    if (!snapshot.exists) return false;
    
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final storedCode = data['code'] as String;
    final expiresAt = DateTime.parse(data['expiresAt'] as String);
    
    if (DateTime.now().isAfter(expiresAt)) {
      // Code expired
      await _database.child('verificationCodes/$emailKey').remove();
      return false;
    }
    
    return storedCode == code;
  }

  Future<void> resetPassword(String identifier, String newPassword, String userType) async {
    final hashedPassword = _hashPassword(newPassword);
    
    if (userType == 'teacher') {
      final teacherId = _sanitizeKey(identifier);
      await _database.child('teachers/$teacherId/password').set(hashedPassword);
    } else {
      final crId = _getCrId(identifier);
      await _database.child('crs/$crId/password').set(hashedPassword);
    }
  }

  Future<String?> findUserByEmail(String email, String userType) async {
    try {
      if (userType == 'teacher') {
        final snapshot = await _database.child('teachers').get();
        if (snapshot.exists) {
          final teachers = Map<String, dynamic>.from(snapshot.value as Map);
          for (var entry in teachers.entries) {
            final data = Map<String, dynamic>.from(entry.value);
            if (data['email'] == email) {
              return data['cnic'] as String?;
            }
          }
        }
      } else {
        final snapshot = await _database.child('crs').get();
        if (snapshot.exists) {
          final crs = Map<String, dynamic>.from(snapshot.value as Map);
          for (var entry in crs.entries) {
            final data = Map<String, dynamic>.from(entry.value);
            if (data['email'] == email) {
              return data['rollNumber'] as String?;
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ Error finding user by email: $e');
      return null;
    }
  }

  // ==================== STUDENT MANAGEMENT ====================

  Future<bool> isStudentRollNumberExists(String crRollNumber, String rollNumber) async {
    final students = await getStudents(crRollNumber);
    return students.any((s) => s.rollNumber.toUpperCase() == rollNumber.toUpperCase());
  }

  Future<void> addStudent(String crRollNumber, Student student) async {
    // Check for duplicate roll number
    final exists = await isStudentRollNumberExists(crRollNumber, student.rollNumber);
    if (exists) {
      throw Exception('Student with roll number ${student.rollNumber} already exists');
    }

    final crId = _getCrId(crRollNumber);
    await _database.child('crs/$crId/students/${student.id}').set(student.toJson());
  }

  Future<void> updateStudent(String crRollNumber, Student student) async {
    final crId = _getCrId(crRollNumber);
    
    // Check if another student has the same roll number
    final students = await getStudents(crRollNumber);
    final duplicate = students.any((s) => 
      s.rollNumber.toUpperCase() == student.rollNumber.toUpperCase() && s.id != student.id);
    
    if (duplicate) {
      throw Exception('Another student with roll number ${student.rollNumber} already exists');
    }

    await _database.child('crs/$crId/students/${student.id}').update(student.toJson());
  }

  Future<void> deleteStudent(String crRollNumber, String studentId) async {
    final crId = _getCrId(crRollNumber);
    await _database.child('crs/$crId/students/$studentId').remove();
  }

  Future<List<Student>> getStudents(String crRollNumber) async {
    final crId = _getCrId(crRollNumber);
    final snapshot = await _database.child('crs/$crId/students').get();

    if (!snapshot.exists) return [];

    final studentsMap = snapshot.value as Map<dynamic, dynamic>;
    return studentsMap.entries.map((entry) {
      return Student.fromJson(
        Map<String, dynamic>.from(entry.value),
        entry.key,
      );
    }).toList();
  }

  // ==================== SUBJECT MANAGEMENT ====================

  Future<bool> isSubjectExists(String crRollNumber, String subjectName) async {
    final subjects = await getSubjects(crRollNumber);
    return subjects.any((s) => s.name.toLowerCase() == subjectName.toLowerCase());
  }

  Future<void> addSubject(String crRollNumber, Subject subject) async {
    // Check for duplicate subject name
    final exists = await isSubjectExists(crRollNumber, subject.name);
    if (exists) {
      throw Exception('Subject "${subject.name}" already exists');
    }

    final crId = _getCrId(crRollNumber);
    await _database.child('crs/$crId/subjects/${subject.id}').set(subject.toJson());
  }

  Future<void> updateSubject(String crRollNumber, Subject subject) async {
    final crId = _getCrId(crRollNumber);
    
    // Check if another subject has the same name
    final subjects = await getSubjects(crRollNumber);
    final duplicate = subjects.any((s) => 
      s.name.toLowerCase() == subject.name.toLowerCase() && s.id != subject.id);
    
    if (duplicate) {
      throw Exception('Another subject with name "${subject.name}" already exists');
    }

    await _database.child('crs/$crId/subjects/${subject.id}').update(subject.toJson());
  }

  Future<void> deleteSubject(String crRollNumber, String subjectId) async {
    final crId = _getCrId(crRollNumber);
    await _database.child('crs/$crId/subjects/$subjectId').remove();
  }

  Future<List<Subject>> getSubjects(String crRollNumber) async {
    final crId = _getCrId(crRollNumber);
    final snapshot = await _database.child('crs/$crId/subjects').get();

    if (!snapshot.exists) return [];

    final subjectsMap = snapshot.value as Map<dynamic, dynamic>;
    return subjectsMap.entries.map((entry) {
      return Subject.fromJson(
        Map<String, dynamic>.from(entry.value),
        entry.key,
      );
    }).toList();
  }

  // ==================== ATTENDANCE MANAGEMENT ====================

  Future<void> markAttendance(
    String crRollNumber,
    String subjectId,
    Map<String, bool> studentAttendance,
    DateTime date,
  ) async {
    final crId = _getCrId(crRollNumber);
    final dateKey =
        '${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

    await _database.child('crs/$crId/attendance/$subjectId/$dateKey').set({
      'date': date.toIso8601String(),
      'students': studentAttendance,
    });
  }

  Future<Map<String, bool>?> getAttendance(
    String crRollNumber,
    String subjectId,
    DateTime date,
  ) async {
    final crId = _getCrId(crRollNumber);
    final dateKey =
        '${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

    final snapshot = await _database
        .child('crs/$crId/attendance/$subjectId/$dateKey/students')
        .get();

    if (!snapshot.exists) return null;

    return Map<String, bool>.from(snapshot.value as Map);
  }

  Future<List<Map<String, dynamic>>> getAttendanceHistory(
    String crRollNumber,
    String subjectId,
  ) async {
    final crId = _getCrId(crRollNumber);
    final snapshot = await _database.child('crs/$crId/attendance/$subjectId').get();

    if (!snapshot.exists) return [];

    final attendanceMap = snapshot.value as Map<dynamic, dynamic>;
    final List<Map<String, dynamic>> result = attendanceMap.entries.map((entry) {
      final data = Map<String, dynamic>.from(entry.value);
      data['dateKey'] = entry.key;
      return data;
    }).toList();
    
    // Sort by date
    result.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });
    
    return result;
  }

  Future<Map<String, List<Map<String, dynamic>>>> getAllAttendanceBySubject(
    String crRollNumber,
  ) async {
    final subjects = await getSubjects(crRollNumber);
    final Map<String, List<Map<String, dynamic>>> result = {};

    for (var subject in subjects) {
      final history = await getAttendanceHistory(crRollNumber, subject.id);
      result[subject.id] = history;
    }

    return result;
  }
}
