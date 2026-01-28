import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/student.dart';
import '../models/subject.dart';
import 'firebase_service.dart';

class ExcelService {
  final FirebaseService _firebaseService = FirebaseService();

  /// Generate Excel file for a specific subject with all attendance data
  Future<String> generateSubjectExcel(
    String crRollNumber,
    Subject subject,
    List<Student> students,
  ) async {
    final excel = Excel.createExcel();
    
    // Remove default sheet and create subject sheet
    excel.delete('Sheet1');
    final sheetName = _sanitizeSheetName(subject.name);
    final sheet = excel[sheetName];

    // Get attendance history for this subject
    final attendanceHistory = await _firebaseService.getAttendanceHistory(
      crRollNumber,
      subject.id,
    );

    // Sort attendance by date
    attendanceHistory.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });

    // Create header row
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4F81BD'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Set headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('S.No')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
      ..value = TextCellValue('Roll Number')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
      ..value = TextCellValue('Email')
      ..cellStyle = headerStyle;

    // Add date columns
    for (int i = 0; i < attendanceHistory.length; i++) {
      final dateStr = attendanceHistory[i]['date'] as String;
      final date = DateTime.parse(dateStr);
      final formattedDate = DateFormat('dd/MM/yy').format(date);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3 + i, rowIndex: 0))
        ..value = TextCellValue(formattedDate)
        ..cellStyle = headerStyle;
    }

    // Add total columns
    final totalColIndex = 3 + attendanceHistory.length;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: totalColIndex, rowIndex: 0))
      ..value = TextCellValue('Present')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: totalColIndex + 1, rowIndex: 0))
      ..value = TextCellValue('Absent')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: totalColIndex + 2, rowIndex: 0))
      ..value = TextCellValue('Percentage')
      ..cellStyle = headerStyle;

    // Student data styles
    final presentStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#C6EFCE'),
      fontColorHex: ExcelColor.fromHexString('#006100'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final absentStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FFC7CE'),
      fontColorHex: ExcelColor.fromHexString('#9C0006'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final normalStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
    );

    // Sort students by roll number
    students.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));

    // Add student rows
    for (int studentIdx = 0; studentIdx < students.length; studentIdx++) {
      final student = students[studentIdx];
      final rowIndex = studentIdx + 1;

      // S.No
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = IntCellValue(studentIdx + 1)
        ..cellStyle = normalStyle;

      // Roll Number
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(student.rollNumber);

      // Email
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(student.email);

      int presentCount = 0;
      int absentCount = 0;

      // Add attendance for each date
      for (int dateIdx = 0; dateIdx < attendanceHistory.length; dateIdx++) {
        final attendance = attendanceHistory[dateIdx];
        final studentsMap = attendance['students'] as Map<dynamic, dynamic>?;
        
        bool? isPresent;
        if (studentsMap != null) {
          isPresent = studentsMap[student.id] as bool?;
        }

        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3 + dateIdx, rowIndex: rowIndex),
        );

        if (isPresent == true) {
          cell.value = TextCellValue('P');
          cell.cellStyle = presentStyle;
          presentCount++;
        } else if (isPresent == false) {
          cell.value = TextCellValue('A');
          cell.cellStyle = absentStyle;
          absentCount++;
        } else {
          cell.value = TextCellValue('-');
          cell.cellStyle = normalStyle;
        }
      }

      // Total Present
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: totalColIndex, rowIndex: rowIndex))
        ..value = IntCellValue(presentCount)
        ..cellStyle = presentStyle;

      // Total Absent
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: totalColIndex + 1, rowIndex: rowIndex))
        ..value = IntCellValue(absentCount)
        ..cellStyle = absentStyle;

      // Percentage
      final total = presentCount + absentCount;
      final percentage = total > 0 ? (presentCount / total * 100).toStringAsFixed(1) : '0.0';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: totalColIndex + 2, rowIndex: rowIndex))
        ..value = TextCellValue('$percentage%')
        ..cellStyle = normalStyle;
    }

    // Set column widths
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 25);
    for (int i = 0; i < attendanceHistory.length; i++) {
      sheet.setColumnWidth(3 + i, 12);
    }
    sheet.setColumnWidth(totalColIndex, 10);
    sheet.setColumnWidth(totalColIndex + 1, 10);
    sheet.setColumnWidth(totalColIndex + 2, 12);

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final attendyDir = Directory('${directory.path}/Attendy/Reports');
    if (!await attendyDir.exists()) {
      await attendyDir.create(recursive: true);
    }

    final fileName = '${_sanitizeFileName(subject.name)}_Attendance.xlsx';
    final filePath = '${attendyDir.path}/$fileName';
    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }

    return filePath;
  }

  /// Generate Excel file with all subjects in separate sheets
  Future<String> generateAllSubjectsExcel(
    String crRollNumber,
    List<Subject> subjects,
    List<Student> students,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    for (var subject in subjects) {
      final sheetName = _sanitizeSheetName(subject.name);
      final sheet = excel[sheetName];

      await _populateSheet(
        sheet,
        crRollNumber,
        subject,
        students,
      );
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final attendyDir = Directory('${directory.path}/Attendy/Reports');
    if (!await attendyDir.exists()) {
      await attendyDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'All_Attendance_$timestamp.xlsx';
    final filePath = '${attendyDir.path}/$fileName';
    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }

    return filePath;
  }

  Future<void> _populateSheet(
    Sheet sheet,
    String crRollNumber,
    Subject subject,
    List<Student> students,
  ) async {
    // Get attendance history for this subject
    final attendanceHistory = await _firebaseService.getAttendanceHistory(
      crRollNumber,
      subject.id,
    );

    // Sort attendance by date
    attendanceHistory.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });

    // Create header row
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4F81BD'),
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Set headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('S.No')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
      ..value = TextCellValue('Roll Number')
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
      ..value = TextCellValue('Email')
      ..cellStyle = headerStyle;

    // Add date columns
    for (int i = 0; i < attendanceHistory.length; i++) {
      final dateStr = attendanceHistory[i]['date'] as String;
      final date = DateTime.parse(dateStr);
      final formattedDate = DateFormat('dd/MM').format(date);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3 + i, rowIndex: 0))
        ..value = TextCellValue(formattedDate)
        ..cellStyle = headerStyle;
    }

    // Add total column
    final totalColIndex = 3 + attendanceHistory.length;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: totalColIndex, rowIndex: 0))
      ..value = TextCellValue('%')
      ..cellStyle = headerStyle;

    // Style definitions
    final presentStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#C6EFCE'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final absentStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FFC7CE'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final normalStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
    );

    // Sort students by roll number
    students.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));

    // Add student rows
    for (int studentIdx = 0; studentIdx < students.length; studentIdx++) {
      final student = students[studentIdx];
      final rowIndex = studentIdx + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = IntCellValue(studentIdx + 1)
        ..cellStyle = normalStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(student.rollNumber);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(student.email);

      int presentCount = 0;
      int totalCount = 0;

      for (int dateIdx = 0; dateIdx < attendanceHistory.length; dateIdx++) {
        final attendance = attendanceHistory[dateIdx];
        final studentsMap = attendance['students'] as Map<dynamic, dynamic>?;
        
        bool? isPresent;
        if (studentsMap != null) {
          isPresent = studentsMap[student.id] as bool?;
        }

        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3 + dateIdx, rowIndex: rowIndex),
        );

        if (isPresent == true) {
          cell.value = TextCellValue('P');
          cell.cellStyle = presentStyle;
          presentCount++;
          totalCount++;
        } else if (isPresent == false) {
          cell.value = TextCellValue('A');
          cell.cellStyle = absentStyle;
          totalCount++;
        } else {
          cell.value = TextCellValue('-');
          cell.cellStyle = normalStyle;
        }
      }

      // Percentage
      final percentage = totalCount > 0 ? (presentCount / totalCount * 100).toStringAsFixed(0) : '0';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: totalColIndex, rowIndex: rowIndex))
        ..value = TextCellValue('$percentage%')
        ..cellStyle = normalStyle;
    }
  }

  /// Share Excel file
  Future<void> shareExcel(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: 'Attendance Report');
  }

  /// Get list of available report files
  Future<List<FileSystemEntity>> getAvailableReports() async {
    final directory = await getApplicationDocumentsDirectory();
    final attendyDir = Directory('${directory.path}/Attendy/Reports');
    
    if (!await attendyDir.exists()) {
      return [];
    }

    return attendyDir.listSync().where((f) => f.path.endsWith('.xlsx')).toList();
  }

  /// Delete a report file
  Future<void> deleteReport(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Sanitize sheet name for Excel (max 31 chars, no special chars)
  String _sanitizeSheetName(String name) {
    String sanitized = name.replaceAll(RegExp(r'[\[\]\*\?:/\\]'), '');
    if (sanitized.length > 31) {
      sanitized = sanitized.substring(0, 31);
    }
    return sanitized;
  }

  /// Sanitize file name
  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
