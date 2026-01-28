import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../services/firebase_service.dart';
import '../services/excel_service.dart';
import '../models/subject.dart';
import '../models/student.dart';

class ViewReportsScreen extends StatefulWidget {
  final String crRollNumber;

  const ViewReportsScreen({super.key, required this.crRollNumber});

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}

class _ViewReportsScreenState extends State<ViewReportsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ExcelService _excelService = ExcelService();
  List<Subject> _subjects = [];
  List<Student> _students = [];
  bool _isLoading = true;
  Map<String, bool> _generatingReport = {};
  Map<String, String?> _generatedPaths = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final subjects = await _firebaseService.getSubjects(widget.crRollNumber);
      final students = await _firebaseService.getStudents(widget.crRollNumber);

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _students = students;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _generateSubjectReport(Subject subject) async {
    setState(() {
      _generatingReport[subject.id] = true;
    });

    try {
      final filePath = await _excelService.generateSubjectExcel(
        widget.crRollNumber,
        subject,
        _students,
      );

      if (mounted) {
        setState(() {
          _generatedPaths[subject.id] = filePath;
          _generatingReport[subject.id] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${subject.name} report generated!')),
              ],
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => _openReport(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error generating report: $e');
      if (mounted) {
        setState(() {
          _generatingReport[subject.id] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateAllReports() async {
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects to generate reports for')),
      );
      return;
    }

    setState(() {
      for (var subject in _subjects) {
        _generatingReport[subject.id] = true;
      }
    });

    try {
      final filePath = await _excelService.generateAllSubjectsExcel(
        widget.crRollNumber,
        _subjects,
        _students,
      );

      if (mounted) {
        setState(() {
          for (var subject in _subjects) {
            _generatingReport[subject.id] = false;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('All reports generated!')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => _openReport(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error generating all reports: $e');
      if (mounted) {
        setState(() {
          for (var subject in _subjects) {
            _generatingReport[subject.id] = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating reports: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openReport(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open file: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  Future<void> _shareReport(Subject subject) async {
    final path = _generatedPaths[subject.id];
    if (path != null && await File(path).exists()) {
      await _excelService.shareExcel(path);
    } else {
      // Generate first, then share
      await _generateSubjectReport(subject);
      final newPath = _generatedPaths[subject.id];
      if (newPath != null) {
        await _excelService.shareExcel(newPath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View Reports',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_subjects.length} subjects',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_subjects.isNotEmpty)
                      IconButton(
                        onPressed: _generatingReport.values.any((v) => v)
                            ? null
                            : _generateAllReports,
                        icon: const Icon(Icons.download_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.purple.withOpacity(0.1),
                          foregroundColor: Colors.purple,
                        ),
                        tooltip: 'Download All',
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _subjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open_outlined,
                                  size: 80,
                                  color: colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No subjects added yet',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add subjects to generate reports',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: _subjects.length,
                            itemBuilder: (context, index) {
                              final subject = _subjects[index];
                              final isGenerating =
                                  _generatingReport[subject.id] ?? false;
                              final hasGenerated =
                                  _generatedPaths[subject.id] != null;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.table_chart,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    title: Text(
                                      subject.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: FutureBuilder<List<Map<String, dynamic>>>(
                                      future: _firebaseService.getAttendanceHistory(
                                        widget.crRollNumber,
                                        subject.id,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final count = snapshot.data!.length;
                                          return Text(
                                            '$count attendance record${count != 1 ? 's' : ''}',
                                            style: TextStyle(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                          );
                                        }
                                        return const Text('Loading...');
                                      },
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isGenerating)
                                          const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        else ...[
                                          IconButton(
                                            onPressed: () =>
                                                _generateSubjectReport(subject),
                                            icon: Icon(
                                              hasGenerated
                                                  ? Icons.refresh
                                                  : Icons.download,
                                              color: Colors.purple,
                                            ),
                                            tooltip: hasGenerated
                                                ? 'Regenerate'
                                                : 'Generate',
                                          ),
                                          if (hasGenerated) ...[
                                            IconButton(
                                              onPressed: () => _openReport(
                                                _generatedPaths[subject.id]!,
                                              ),
                                              icon: const Icon(
                                                Icons.open_in_new,
                                                color: Colors.blue,
                                              ),
                                              tooltip: 'Open',
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  _shareReport(subject),
                                              icon: const Icon(
                                                Icons.share,
                                                color: Colors.green,
                                              ),
                                              tooltip: 'Share',
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // Info Card
              if (!_isLoading && _subjects.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Excel reports include all attendance records with dates, present/absent status, and percentage for each student.',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
