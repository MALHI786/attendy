import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/whatsapp_service.dart';
import '../models/subject.dart';
import '../models/student.dart';

class WhatsAppAbsenteeScreen extends StatefulWidget {
  final String crRollNumber;

  const WhatsAppAbsenteeScreen({
    super.key,
    required this.crRollNumber,
  });

  @override
  State<WhatsAppAbsenteeScreen> createState() => _WhatsAppAbsenteeScreenState();
}

class _WhatsAppAbsenteeScreenState extends State<WhatsAppAbsenteeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final WhatsAppService _whatsAppService = WhatsAppService();
  
  List<Subject> _subjects = [];
  List<Student> _students = [];
  Subject? _selectedSubject;
  DateTime _selectedDate = DateTime.now();
  
  List<String> _absenteeRollNumbers = [];
  bool _isLoading = true;
  bool _isFetchingAttendance = false;
  bool _hasFetchedAttendance = false;
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _customHeaderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _customHeaderController.dispose();
    super.dispose();
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

  Future<void> _fetchAbsentees() async {
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject first')),
      );
      return;
    }

    setState(() {
      _isFetchingAttendance = true;
      _hasFetchedAttendance = false;
      _absenteeRollNumbers = [];
    });

    try {
      final attendance = await _firebaseService.getAttendance(
        widget.crRollNumber,
        _selectedSubject!.id,
        _selectedDate,
      );

      if (attendance == null) {
        if (mounted) {
          setState(() {
            _isFetchingAttendance = false;
            _hasFetchedAttendance = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No attendance record found for ${_selectedSubject!.name} on ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Find absentees
      final absentees = <String>[];
      for (var student in _students) {
        final isPresent = attendance[student.id] ?? false;
        if (!isPresent) {
          absentees.add(student.rollNumber);
        }
      }

      // Sort roll numbers
      absentees.sort((a, b) => a.compareTo(b));

      if (mounted) {
        setState(() {
          _absenteeRollNumbers = absentees;
          _isFetchingAttendance = false;
          _hasFetchedAttendance = true;
        });
      }
    } catch (e) {
      print('Error fetching attendance: $e');
      if (mounted) {
        setState(() {
          _isFetchingAttendance = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching attendance: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hasFetchedAttendance = false;
        _absenteeRollNumbers = [];
      });
    }
  }

  Future<void> _shareToWhatsApp() async {
    if (!_hasFetchedAttendance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fetch absentees first')),
      );
      return;
    }

    final message = _whatsAppService.formatAbsenteeMessage(
      subjectName: _selectedSubject!.name,
      date: _selectedDate,
      absenteeRollNumbers: _absenteeRollNumbers,
      customHeader: _customHeaderController.text.isEmpty 
          ? null 
          : _customHeaderController.text,
    );

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.message, color: Colors.green.shade700),
            const SizedBox(width: 12),
            const Flexible(child: Text('Send to WhatsApp')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Message Preview:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  hintText: '+91 9876543210',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Leave empty to choose contact in WhatsApp',
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.send),
            label: const Text('Send'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _whatsAppService.shareToWhatsApp(
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        message: message,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Make sure it is installed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Absentees'),
        centerTitle: true,
        elevation: 0,
      ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.message,
                              color: Colors.green.shade700,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WhatsApp Sharing',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Share absentee roll numbers directly to WhatsApp',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Subject Selection
                    Text(
                      'Select Subject',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Subject>(
                          value: _selectedSubject,
                          isExpanded: true,
                          hint: const Text('Choose a subject'),
                          items: _subjects.map((subject) {
                            return DropdownMenuItem(
                              value: subject,
                              child: Text(subject.name),
                            );
                          }).toList(),
                          onChanged: (subject) {
                            setState(() {
                              _selectedSubject = subject;
                              _hasFetchedAttendance = false;
                              _absenteeRollNumbers = [];
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date Selection
                    Text(
                      'Select Date',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Icon(Icons.edit, color: colorScheme.primary, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Custom Header (Optional)
                    Text(
                      'Custom Header (Optional)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customHeaderController,
                      decoration: InputDecoration(
                        hintText: 'e.g., "Absentees for today\'s class"',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Fetch Button
                    FilledButton.icon(
                      onPressed: _isFetchingAttendance ? null : _fetchAbsentees,
                      icon: _isFetchingAttendance 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        _isFetchingAttendance ? 'Fetching...' : 'Fetch Absentees',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Results Section
                    if (_hasFetchedAttendance) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _absenteeRollNumbers.isEmpty 
                                      ? Icons.check_circle 
                                      : Icons.warning_amber_rounded,
                                  color: _absenteeRollNumbers.isEmpty 
                                      ? Colors.green 
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _absenteeRollNumbers.isEmpty
                                        ? 'All students present!'
                                        : '${_absenteeRollNumbers.length} student(s) absent',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _absenteeRollNumbers.isEmpty 
                                          ? Colors.green.shade700 
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_absenteeRollNumbers.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),
                              Text(
                                'Absent Roll Numbers:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _absenteeRollNumbers.map((roll) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Text(
                                      roll,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Share Button
                      FilledButton.icon(
                        onPressed: _shareToWhatsApp,
                        icon: const Icon(Icons.message),
                        label: const Text('Share to WhatsApp'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }
}
