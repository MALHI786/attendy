import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';
import '../models/student.dart';
import '../models/subject.dart';

/// Service to handle offline data storage and sync when back online
class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isOnline = true;
  bool _isSyncing = false;
  
  // SharedPreferences keys
  static const String _pendingStudentsKey = 'pending_students';
  static const String _pendingSubjectsKey = 'pending_subjects';
  static const String _pendingAttendanceKey = 'pending_attendance';
  static const String _universityTypeKey = 'university_type';
  
  /// Initialize the service and start listening for connectivity changes
  Future<void> initialize() async {
    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);
      
      // If we just came online, sync pending data
      if (!wasOnline && _isOnline) {
        debugPrint('📶 Back online! Syncing pending data...');
        syncPendingData();
      }
    });
    
    debugPrint('✅ OfflineSyncService initialized, Online: $_isOnline');
  }
  
  /// Check if device is currently online
  bool get isOnline => _isOnline;
  
  /// Get the saved university type (ntu or other)
  Future<String> getUniversityType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_universityTypeKey) ?? 'ntu';
  }
  
  /// Save the university type
  Future<void> setUniversityType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_universityTypeKey, type);
    debugPrint('✅ University type saved: $type');
  }
  
  /// Dispose the service
  void dispose() {
    _connectivitySubscription?.cancel();
  }
  
  // ============ STUDENT OPERATIONS ============
  
  /// Add a student - works offline and syncs when online
  Future<bool> addStudent({
    required String crRollNumber,
    required Student student,
  }) async {
    if (_isOnline) {
      // Online: add directly to Firebase
      try {
        await _firebaseService.addStudent(crRollNumber, student);
        return true;
      } catch (e) {
        debugPrint('❌ Error adding student online: $e');
        // Fall back to offline storage
        await _queueStudent(crRollNumber, student);
        return true;
      }
    } else {
      // Offline: queue for later sync
      await _queueStudent(crRollNumber, student);
      debugPrint('📴 Student queued for offline sync: ${student.rollNumber}');
      return true;
    }
  }
  
  Future<void> _queueStudent(String crRollNumber, Student student) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingList = prefs.getStringList(_pendingStudentsKey) ?? [];
    
    final studentData = jsonEncode({
      'crRollNumber': crRollNumber,
      'student': student.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    pendingList.add(studentData);
    await prefs.setStringList(_pendingStudentsKey, pendingList);
  }
  
  // ============ SUBJECT OPERATIONS ============
  
  /// Add a subject - works offline and syncs when online
  Future<bool> addSubject({
    required String crRollNumber,
    required Subject subject,
  }) async {
    if (_isOnline) {
      try {
        await _firebaseService.addSubject(crRollNumber, subject);
        return true;
      } catch (e) {
        debugPrint('❌ Error adding subject online: $e');
        await _queueSubject(crRollNumber, subject);
        return true;
      }
    } else {
      await _queueSubject(crRollNumber, subject);
      debugPrint('📴 Subject queued for offline sync: ${subject.name}');
      return true;
    }
  }
  
  Future<void> _queueSubject(String crRollNumber, Subject subject) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingList = prefs.getStringList(_pendingSubjectsKey) ?? [];
    
    final subjectData = jsonEncode({
      'crRollNumber': crRollNumber,
      'subject': subject.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    pendingList.add(subjectData);
    await prefs.setStringList(_pendingSubjectsKey, pendingList);
  }
  
  // ============ ATTENDANCE OPERATIONS ============
  
  /// Mark attendance - works offline and syncs when online
  Future<bool> markAttendance({
    required String crRollNumber,
    required String subjectId,
    required Map<String, bool> studentAttendance,
    required DateTime date,
  }) async {
    if (_isOnline) {
      try {
        await _firebaseService.markAttendance(
          crRollNumber,
          subjectId,
          studentAttendance,
          date,
        );
        return true;
      } catch (e) {
        debugPrint('❌ Error saving attendance online: $e');
        await _queueAttendance(crRollNumber, subjectId, studentAttendance, date);
        return true;
      }
    } else {
      await _queueAttendance(crRollNumber, subjectId, studentAttendance, date);
      debugPrint('📴 Attendance queued for offline sync: $subjectId on $date');
      return true;
    }
  }
  
  Future<void> _queueAttendance(
    String crRollNumber,
    String subjectId,
    Map<String, bool> studentAttendance,
    DateTime date,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingList = prefs.getStringList(_pendingAttendanceKey) ?? [];
    
    final attendanceRecord = jsonEncode({
      'crRollNumber': crRollNumber,
      'subjectId': subjectId,
      'studentAttendance': studentAttendance,
      'date': date.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    pendingList.add(attendanceRecord);
    await prefs.setStringList(_pendingAttendanceKey, pendingList);
  }
  
  // ============ SYNC OPERATIONS ============
  
  /// Sync all pending data to Firebase
  Future<Map<String, int>> syncPendingData() async {
    if (_isSyncing) {
      debugPrint('⚠️ Already syncing, skipping...');
      return {'students': 0, 'subjects': 0, 'attendance': 0};
    }
    
    if (!_isOnline) {
      debugPrint('📴 Cannot sync while offline');
      return {'students': 0, 'subjects': 0, 'attendance': 0};
    }
    
    _isSyncing = true;
    int studentsSynced = 0;
    int subjectsSynced = 0;
    int attendanceSynced = 0;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Sync pending students
      studentsSynced = await _syncPendingStudents(prefs);
      
      // Sync pending subjects
      subjectsSynced = await _syncPendingSubjects(prefs);
      
      // Sync pending attendance
      attendanceSynced = await _syncPendingAttendance(prefs);
      
      debugPrint('✅ Sync complete: $studentsSynced students, $subjectsSynced subjects, $attendanceSynced attendance records');
    } catch (e) {
      debugPrint('❌ Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
    
    return {
      'students': studentsSynced,
      'subjects': subjectsSynced,
      'attendance': attendanceSynced,
    };
  }
  
  Future<int> _syncPendingStudents(SharedPreferences prefs) async {
    final pendingList = prefs.getStringList(_pendingStudentsKey) ?? [];
    if (pendingList.isEmpty) return 0;
    
    final failedItems = <String>[];
    int synced = 0;
    
    for (final item in pendingList) {
      try {
        final data = jsonDecode(item) as Map<String, dynamic>;
        final studentJson = data['student'] as Map<String, dynamic>;
        final student = Student(
          id: studentJson['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          rollNumber: studentJson['rollNumber'] ?? '',
          email: studentJson['email'] ?? '',
          password: studentJson['password'],
          emailVerified: studentJson['emailVerified'] ?? false,
        );
        await _firebaseService.addStudent(
          data['crRollNumber'],
          student,
        );
        synced++;
      } catch (e) {
        debugPrint('❌ Failed to sync student: $e');
        failedItems.add(item);
      }
    }
    
    await prefs.setStringList(_pendingStudentsKey, failedItems);
    return synced;
  }
  
  Future<int> _syncPendingSubjects(SharedPreferences prefs) async {
    final pendingList = prefs.getStringList(_pendingSubjectsKey) ?? [];
    if (pendingList.isEmpty) return 0;
    
    final failedItems = <String>[];
    int synced = 0;
    
    for (final item in pendingList) {
      try {
        final data = jsonDecode(item) as Map<String, dynamic>;
        final subjectJson = data['subject'] as Map<String, dynamic>;
        final subject = Subject(
          id: subjectJson['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: subjectJson['name'] ?? '',
        );
        await _firebaseService.addSubject(
          data['crRollNumber'],
          subject,
        );
        synced++;
      } catch (e) {
        debugPrint('❌ Failed to sync subject: $e');
        failedItems.add(item);
      }
    }
    
    await prefs.setStringList(_pendingSubjectsKey, failedItems);
    return synced;
  }
  
  Future<int> _syncPendingAttendance(SharedPreferences prefs) async {
    final pendingList = prefs.getStringList(_pendingAttendanceKey) ?? [];
    if (pendingList.isEmpty) return 0;
    
    final failedItems = <String>[];
    int synced = 0;
    
    for (final item in pendingList) {
      try {
        final data = jsonDecode(item) as Map<String, dynamic>;
        final studentAttendance = Map<String, bool>.from(data['studentAttendance']);
        final date = DateTime.parse(data['date']);
        
        await _firebaseService.markAttendance(
          data['crRollNumber'],
          data['subjectId'],
          studentAttendance,
          date,
        );
        synced++;
      } catch (e) {
        debugPrint('❌ Failed to sync attendance: $e');
        failedItems.add(item);
      }
    }
    
    await prefs.setStringList(_pendingAttendanceKey, failedItems);
    return synced;
  }
  
  /// Get count of pending items
  Future<Map<String, int>> getPendingCounts() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'students': (prefs.getStringList(_pendingStudentsKey) ?? []).length,
      'subjects': (prefs.getStringList(_pendingSubjectsKey) ?? []).length,
      'attendance': (prefs.getStringList(_pendingAttendanceKey) ?? []).length,
    };
  }
  
  /// Check if there are pending items to sync
  Future<bool> hasPendingData() async {
    final counts = await getPendingCounts();
    return counts['students']! > 0 || counts['subjects']! > 0 || counts['attendance']! > 0;
  }
}
