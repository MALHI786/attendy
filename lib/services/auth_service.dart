import 'dart:math';
import 'firebase_service.dart';
import 'email_service.dart';

class AuthService {
  final FirebaseService _firebaseService = FirebaseService();
  final EmailService _emailService = EmailService();

  /// Generate a 6-digit verification code
  String generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send verification code to email via SMTP
  Future<String> sendVerificationCode(String email) async {
    final code = generateVerificationCode();
    
    // Store the code in Firebase for verification later
    await _firebaseService.storeVerificationCode(email, code);
    
    // Send actual email with the code
    final emailSent = await _emailService.sendVerificationEmail(email, code);
    
    if (emailSent) {
      print('✅ Verification email sent to $email');
    } else {
      print('❌ Failed to send email to $email');
      // In production, you might want to throw an exception here
      // For now, we'll still return the code for demo purposes
    }
    
    return code;
  }

  /// Verify the code entered by user
  Future<bool> verifyCode(String email, String code) async {
    return await _firebaseService.verifyCode(email, code);
  }

  /// Reset password after verification
  Future<void> resetPassword(
    String identifier, 
    String newPassword, 
    String userType,
  ) async {
    await _firebaseService.resetPassword(identifier, newPassword, userType);
  }

  /// Find user by email
  Future<String?> findUserByEmail(String email, String userType) async {
    return await _firebaseService.findUserByEmail(email, userType);
  }

  /// Validate CNIC format (xxxxx-xxxxxxx-x)
  static bool isValidCnic(String cnic) {
    final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    return regex.hasMatch(cnic);
  }

  /// Format CNIC with dashes
  static String formatCnic(String cnic) {
    // Remove any existing dashes
    final digitsOnly = cnic.replaceAll('-', '');
    if (digitsOnly.length != 13) return cnic;
    
    return '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5, 12)}-${digitsOnly.substring(12)}';
  }
}
