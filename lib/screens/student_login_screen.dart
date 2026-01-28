import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/offline_sync_service.dart';
import '../utils/validators.dart';
import 'dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'firebase_email_verification_screen.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rollNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _semesterController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isNewUser = false;
  
  @override
  void dispose() {
    _rollNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rollNumber = _rollNumberController.text.trim().toUpperCase();
      final password = _passwordController.text;

      print('🔐 LOGIN ATTEMPT: $rollNumber');

      // Try to get email (this will work without auth if rules allow)
      final email = await _firebaseService.getCrEmail(rollNumber);

      if (email != null) {
        final success = await _firebaseService.loginCr(rollNumber, password, email);

        if (success) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  userIdentifier: rollNumber,
                  userType: 'student',
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid password')),
            );
          }
        }
      } else {
        setState(() => _isNewUser = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final semester = int.tryParse(_semesterController.text);
    if (semester == null || semester < 1 || semester > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid semester (1-8)')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rollNumber = _rollNumberController.text.trim().toUpperCase();
      final password = _passwordController.text;
      final email = _emailController.text.trim();

      // Register the student with Firebase Auth first
      await _firebaseService.registerCr(
        rollNumber,
        password,
        email,
        semester,
      );

      // Navigate to Firebase email verification screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirebaseEmailVerificationScreen(
              email: email,
              onVerified: () async {
                await _firebaseService.updateCrEmailVerified(rollNumber, true);

                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(
                        userIdentifier: rollNumber,
                        userType: 'student',
                      ),
                    ),
                  );
                }
              },
              onCancel: () {
                // If user cancels, sign them out and go back
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final user = await _googleAuthService.signInWithGoogle();

      if (user == null) {
        // User cancelled
        return;
      }

      // Check if this student already exists in database
      final email = user.email;
      if (email == null) {
        throw Exception('No email associated with Google account');
      }

      // Try to find existing student by email
      final existingRollNumber = await _firebaseService.findUserByEmail(email, 'student');

      if (existingRollNumber != null) {
        // Existing student - login directly
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userIdentifier: existingRollNumber,
                userType: 'student',
              ),
            ),
          );
        }
      } else {
        // New student - need to complete registration
        if (mounted) {
          _showGoogleRegistrationDialog(user);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In error: $e')),
        );
      }
    } finally {
      setState(() => _isGoogleLoading = false);
    }
  }

  void _showGoogleRegistrationDialog(User user) {
    final rollNumberController = TextEditingController();
    final semesterController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPasswordVisible = false;
    bool isConfirmPasswordVisible = false;
    String? rollNumberError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Complete Registration'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${user.email}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: rollNumberController,
                    decoration: InputDecoration(
                      labelText: 'Roll Number *',
                      hintText: '23-NTU-CS-1272',
                      helperText: 'Format: XX-NTU-YY-ZZZZ',
                      errorText: rollNumberError,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.badge),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      final upperValue = value.toUpperCase();
                      if (!Validators.rollNumberRegex.hasMatch(upperValue) && value.isNotEmpty) {
                        setDialogState(() {
                          rollNumberError = 'Format: XX-NTU-YY-ZZZZ (e.g., 23-NTU-CS-1272)';
                        });
                      } else {
                        setDialogState(() {
                          rollNumberError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: semesterController,
                    decoration: const InputDecoration(
                      labelText: 'Semester (1-8) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateSemester,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      helperText: 'Min 6 characters (for future login)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => isPasswordVisible = !isPasswordVisible),
                      ),
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                      ),
                    ),
                    validator: (value) => Validators.validateConfirmPassword(value, passwordController.text),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _googleAuthService.signOut();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final rollNumber = rollNumberController.text.trim().toUpperCase();
                final semester = int.tryParse(semesterController.text);
                final password = passwordController.text;

                // Validate roll number format
                if (!Validators.rollNumberRegex.hasMatch(rollNumber)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid roll number format. Use: XX-NTU-YY-ZZZZ')),
                  );
                  return;
                }

                if (!formKey.currentState!.validate()) {
                  return;
                }

                if (semester == null || semester < 1 || semester > 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid semester (1-8)')),
                  );
                  return;
                }

                Navigator.pop(context);

                // Capture scaffold messenger before async operation
                final scaffoldMessenger = ScaffoldMessenger.of(this.context);

                // Register student with Google account (including password)
                await _firebaseService.registerCrWithGoogle(
                  rollNumber,
                  user.email!,
                  semester,
                  user.uid,
                  password: password,
                );

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('✅ Registration successful! Welcome to Attendy.'),
                    backgroundColor: Colors.green,
                  ),
                );

                if (mounted) {
                  Navigator.pushReplacement(
                    this.context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(
                        userIdentifier: rollNumber,
                        userType: 'student',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Complete Registration'),
            ),
          ],
        ),
      ),
    );
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
              // Back Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.blue.shade700],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Student Login',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isNewUser
                                ? 'Create Your Account'
                                : 'Class Representative',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Login Card
                          Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Roll Number
                                TextFormField(
                                  controller: _rollNumberController,
                                  decoration: InputDecoration(
                                    labelText: 'Roll Number',
                                    hintText: 'XX-NTU-XX-XXXX',
                                    prefixIcon: const Icon(Icons.badge_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    filled: true,
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                  validator: Validators.validateRollNumber,
                                  enabled: !_isLoading && !_isNewUser,
                                ),
                                const SizedBox(height: 16),

                                // Email (for new users)
                                if (_isNewUser) ...[
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Gmail',
                                      hintText: 'your.email@gmail.com',
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      filled: true,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: Validators.validateEmail,
                                    enabled: !_isLoading,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: _isNewUser
                                        ? 'Set your password'
                                        : 'Enter password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    filled: true,
                                  ),
                                  obscureText: !_isPasswordVisible,
                                  validator: Validators.validatePassword,
                                  enabled: !_isLoading,
                                ),

                                // Confirm Password (for new users)
                                if (_isNewUser) ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      hintText: 'Re-enter password',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      filled: true,
                                    ),
                                    obscureText: !_isConfirmPasswordVisible,
                                    validator: (value) => Validators.validateConfirmPassword(
                                      value,
                                      _passwordController.text,
                                    ),
                                    enabled: !_isLoading,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _semesterController,
                                    decoration: InputDecoration(
                                      labelText: 'Semester',
                                      hintText: '1-8',
                                      prefixIcon: const Icon(Icons.calendar_today),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      filled: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: Validators.validateSemester,
                                    enabled: !_isLoading,
                                  ),
                                ],

                                // Forgot Password
                                if (!_isNewUser) ...[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordScreen(
                                              userType: 'student',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Forgot Password?'),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 16),

                                // Login/Register Button
                                FilledButton(
                                  onPressed: _isLoading
                                      ? null
                                      : (_isNewUser
                                          ? _handleRegister
                                          : _handleLogin),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isNewUser ? 'Create Account' : 'Login',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),

                                if (_isNewUser) ...[
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isNewUser = false;
                                        _semesterController.clear();
                                        _emailController.clear();
                                        _confirmPasswordController.clear();
                                      });
                                    },
                                    child: const Text('Back to Login'),
                                  ),
                                ],

                                // Divider with OR
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.grey[400])),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.grey[400])),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Google Sign-In Button
                                OutlinedButton.icon(
                                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  icon: _isGoogleLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Image.network(
                                          'https://www.google.com/favicon.ico',
                                          height: 24,
                                          width: 24,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
                                        ),
                                  label: const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
