import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/attendance_email_service.dart';
import 'student_management_screen.dart';
import 'subject_management_screen.dart';
import 'attendance_screen.dart';
import 'view_reports_screen.dart';
import 'user_type_screen.dart';
import 'whatsapp_absentee_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userIdentifier;
  final String userType;

  const DashboardScreen({
    super.key,
    required this.userIdentifier,
    required this.userType,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AttendanceEmailService _emailService = AttendanceEmailService();
  int? _semester;
  int _studentCount = 0;
  int _subjectCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final semester = await _firebaseService.getSemester();
      final students = await _firebaseService.getStudents(widget.userIdentifier);
      final subjects = await _firebaseService.getSubjects(widget.userIdentifier);

      if (mounted) {
        setState(() {
          _semester = semester;
          _studentCount = students.length;
          _subjectCount = subjects.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (widget.userType == 'teacher') {
        await _firebaseService.logoutTeacher();
      } else {
        await _firebaseService.logoutCr();
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserTypeScreen()),
        );
      }
    }
  }

  Future<void> _editSemester() async {
    final controller = TextEditingController(text: _semester?.toString() ?? '');
    
    final newSemester = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Semester'),
        content: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Semester',
            hintText: '1-8',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 1 && value <= 8) {
                Navigator.pop(context, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter semester between 1-8')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newSemester != null) {
      await _firebaseService.updateSemester(
        widget.userIdentifier,
        newSemester,
        widget.userType,
      );
      setState(() => _semester = newSemester);
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dashboard',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        widget.userType == 'teacher'
                                            ? Icons.school
                                            : Icons.person,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.userIdentifier,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: _handleLogout,
                                icon: const Icon(Icons.logout),
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme.surface,
                                ),
                                tooltip: 'Logout',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Stats Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  Icons.school,
                                  'Semester',
                                  _semester?.toString() ?? '-',
                                  colorScheme,
                                  onTap: _editSemester,
                                ),
                                _buildStatItem(
                                  Icons.people,
                                  'Students',
                                  '$_studentCount/50',
                                  colorScheme,
                                ),
                                _buildStatItem(
                                  Icons.book,
                                  'Subjects',
                                  _subjectCount.toString(),
                                  colorScheme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu Options
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildMenuCard(
                              context,
                              'Add Students',
                              Icons.person_add_rounded,
                              Colors.blue,
                              () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentManagementScreen(
                                      crRollNumber: widget.userIdentifier,
                                    ),
                                  ),
                                );
                                _loadData();
                              },
                            ),
                            _buildMenuCard(
                              context,
                              'Add Subjects',
                              Icons.library_add_rounded,
                              Colors.green,
                              () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubjectManagementScreen(
                                      crRollNumber: widget.userIdentifier,
                                    ),
                                  ),
                                );
                                _loadData();
                              },
                            ),
                            _buildMenuCard(
                              context,
                              'Mark Attendance',
                              Icons.check_circle_rounded,
                              Colors.orange,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AttendanceScreen(
                                      crRollNumber: widget.userIdentifier,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildMenuCard(
                              context,
                              'View Reports',
                              Icons.analytics_rounded,
                              Colors.purple,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewReportsScreen(
                                      crRollNumber: widget.userIdentifier,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildMenuCard(
                              context,
                              'AI Features',
                              Icons.psychology_rounded,
                              Colors.cyan,
                              () {
                                // Coming soon - AI features will be implemented here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('AI Features coming soon!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              subtitle: 'Coming Soon',
                            ),
                            _buildMenuCard(
                              context,
                              'WhatsApp Share',
                              Icons.message_rounded,
                              Colors.green,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WhatsAppAbsenteeScreen(
                                      crRollNumber: widget.userIdentifier,
                                    ),
                                  ),
                                );
                              },
                              subtitle: 'Share Absentees',
                            ),
                            _buildMenuCard(
                              context,
                              'Send Gmails',
                              Icons.email_rounded,
                              Colors.orange,
                              () => _showEmailConfirmation(context),
                              subtitle: 'Low Attendance Alert',
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

  void _showEmailConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.email_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Send Emails',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.check_circle, 'Analyze all attendance records'),
              _buildInfoRow(Icons.warning_amber, 'Find students with < 75% attendance'),
              _buildInfoRow(Icons.mail, 'Send email alerts to affected students'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Make sure email credentials are configured in EmailService',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendLowAttendanceEmails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Send Emails'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendLowAttendanceEmails() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Sending emails...')),
            ],
          ),
        );
      },
    );

    try {
      final result = await _emailService.sendLowAttendanceNotifications(
        widget.userIdentifier,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show result dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final success = result['success'] as bool;
            final message = result['message'] as String;
            final emailsSent = result['emailsSent'] as int;
            final emailsFailed = result['emailsFailed'] as int? ?? 0;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: success ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Text(success ? 'Success!' : 'Error'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message),
                  if (emailsSent > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.email, color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$emailsSent email(s) sent',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (emailsFailed > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$emailsFailed failed',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colorScheme.primary, size: 28),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    color: colorScheme.primary.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
