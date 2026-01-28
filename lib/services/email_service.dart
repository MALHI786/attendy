import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';
import 'env_config.dart';

class EmailService {
  // Get credentials from environment variables
  String get _senderEmail => EnvConfig.smtpEmail;
  String get _senderPassword => EnvConfig.smtpPassword;
  String get _senderName => EnvConfig.smtpSenderName;

  /// Check if email service is properly configured
  bool get isConfigured => EnvConfig.isEmailConfigured;

  /// Send verification code email
  Future<bool> sendVerificationEmail(String recipientEmail, String code) async {
    if (!isConfigured) {
      debugPrint('⚠️ Email not configured. Please set SMTP_EMAIL and SMTP_PASSWORD in .env file');
      return false;
    }
    
    try {
      // Configure SMTP server for Gmail with SSL
      final smtpServer = gmail(_senderEmail, _senderPassword);

      // Create email message with improved headers for deliverability
      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(recipientEmail)
        ..subject = 'Attendy - Your Verification Code'
        ..headers = {
          'X-Priority': '1',
          'X-Mailer': 'Attendy App',
          'List-Unsubscribe': '<mailto:$_senderEmail?subject=unsubscribe>',
        }
        ..html = '''
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { 
                font-family: Arial, sans-serif; 
                line-height: 1.6;
                color: #333;
              }
              .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f9f9f9;
              }
              .header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 30px;
                text-align: center;
                border-radius: 10px 10px 0 0;
              }
              .content {
                background: white;
                padding: 30px;
                border-radius: 0 0 10px 10px;
              }
              .code-box {
                background: #f0f4ff;
                border: 2px solid #667eea;
                border-radius: 8px;
                padding: 20px;
                text-align: center;
                margin: 20px 0;
              }
              .code {
                font-size: 32px;
                font-weight: bold;
                color: #667eea;
                letter-spacing: 5px;
              }
              .warning {
                background: #fff3cd;
                border-left: 4px solid #ffc107;
                padding: 12px;
                margin: 20px 0;
                border-radius: 4px;
              }
              .footer {
                text-align: center;
                color: #666;
                font-size: 12px;
                margin-top: 20px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>📱 Attendy Verification</h1>
              </div>
              <div class="content">
                <h2>Hello!</h2>
                <p>You requested a verification code for your Attendy account.</p>
                
                <div class="code-box">
                  <p style="margin: 0; font-size: 14px; color: #666;">Your Verification Code:</p>
                  <div class="code">$code</div>
                </div>
                
                <p>Enter this code in the Attendy app to verify your account.</p>
                
                <div class="warning">
                  <strong>⚠️ Security Note:</strong>
                  <ul style="margin: 10px 0;">
                    <li>This code expires in <strong>10 minutes</strong></li>
                    <li>Never share this code with anyone</li>
                    <li>Attendy staff will never ask for your verification code</li>
                  </ul>
                </div>
                
                <p>If you didn't request this code, please ignore this email or contact support if you have concerns.</p>
                
                <p>Best regards,<br><strong>The Attendy Team</strong></p>
              </div>
              <div class="footer">
                <p>This is an automated email. Please do not reply to this message.</p>
                <p>&copy; 2026 Attendy App. All rights reserved.</p>
              </div>
            </div>
          </body>
          </html>
        ''';

      // Send email
      final sendReport = await send(message, smtpServer);
      print('✅ Email sent successfully: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('❌ Error sending email: $e');
      
      // Provide helpful error messages
      if (e.toString().contains('Invalid login')) {
        print('💡 TIP: For Gmail, create an App Password:');
        print('   1. Go to Google Account > Security');
        print('   2. Enable 2-Step Verification');
        print('   3. Generate App Password for "Mail"');
        print('   4. Use that password in _senderPassword');
      }
      
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String recipientEmail, String code) async {
    if (!isConfigured) {
      debugPrint('⚠️ Email not configured. Please set SMTP_EMAIL and SMTP_PASSWORD in .env file');
      return false;
    }
    
    try {
      final smtpServer = gmail(_senderEmail, _senderPassword);

      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(recipientEmail)
        ..subject = 'Attendy - Password Reset Code'
        ..headers = {
          'X-Priority': '1',
          'X-Mailer': 'Attendy App',
        }
        ..html = '''
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { 
                font-family: Arial, sans-serif; 
                line-height: 1.6;
                color: #333;
              }
              .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f9f9f9;
              }
              .header {
                background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                color: white;
                padding: 30px;
                text-align: center;
                border-radius: 10px 10px 0 0;
              }
              .content {
                background: white;
                padding: 30px;
                border-radius: 0 0 10px 10px;
              }
              .code-box {
                background: #fff0f5;
                border: 2px solid #f5576c;
                border-radius: 8px;
                padding: 20px;
                text-align: center;
                margin: 20px 0;
              }
              .code {
                font-size: 32px;
                font-weight: bold;
                color: #f5576c;
                letter-spacing: 5px;
              }
              .warning {
                background: #ffe5e5;
                border-left: 4px solid #dc3545;
                padding: 12px;
                margin: 20px 0;
                border-radius: 4px;
              }
              .footer {
                text-align: center;
                color: #666;
                font-size: 12px;
                margin-top: 20px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>🔐 Password Reset Request</h1>
              </div>
              <div class="content">
                <h2>Hello!</h2>
                <p>We received a request to reset your Attendy password.</p>
                
                <div class="code-box">
                  <p style="margin: 0; font-size: 14px; color: #666;">Your Reset Code:</p>
                  <div class="code">$code</div>
                </div>
                
                <p>Enter this code in the Attendy app to reset your password.</p>
                
                <div class="warning">
                  <strong>⚠️ Security Warning:</strong>
                  <ul style="margin: 10px 0;">
                    <li>This code expires in <strong>10 minutes</strong></li>
                    <li>If you didn't request this, <strong>ignore this email</strong></li>
                    <li>Your password has NOT been changed yet</li>
                    <li>Never share this code with anyone</li>
                  </ul>
                </div>
                
                <p>If you didn't request a password reset, your account is still secure. No action is needed.</p>
                
                <p>Best regards,<br><strong>The Attendy Team</strong></p>
              </div>
              <div class="footer">
                <p>This is an automated email. Please do not reply to this message.</p>
                <p>&copy; 2026 Attendy App. All rights reserved.</p>
              </div>
            </div>
          </body>
          </html>
        ''';

      final sendReport = await send(message, smtpServer);
      print('✅ Password reset email sent: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      return false;
    }
  }

  /// Send welcome email after successful registration
  Future<bool> sendWelcomeEmail(String recipientEmail, String name, String userType) async {
    if (!isConfigured) {
      debugPrint('⚠️ Email not configured. Please set SMTP_EMAIL and SMTP_PASSWORD in .env file');
      return false;
    }
    
    try {
      final smtpServer = gmail(_senderEmail, _senderPassword);

      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(recipientEmail)
        ..subject = 'Welcome to Attendy! 🎉'
        ..headers = {
          'X-Priority': '3',
          'X-Mailer': 'Attendy App',
        }
        ..html = '''
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { 
                font-family: Arial, sans-serif; 
                line-height: 1.6;
                color: #333;
              }
              .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f9f9f9;
              }
              .header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 30px;
                text-align: center;
                border-radius: 10px 10px 0 0;
              }
              .content {
                background: white;
                padding: 30px;
                border-radius: 0 0 10px 10px;
              }
              .badge {
                display: inline-block;
                background: #667eea;
                color: white;
                padding: 5px 15px;
                border-radius: 20px;
                font-size: 14px;
                font-weight: bold;
              }
              .footer {
                text-align: center;
                color: #666;
                font-size: 12px;
                margin-top: 20px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>🎉 Welcome to Attendy!</h1>
              </div>
              <div class="content">
                <h2>Hello $name!</h2>
                <p>Your account has been successfully verified. <span class="badge">${userType.toUpperCase()}</span></p>
                
                <p>Thank you for joining Attendy - your smart attendance management solution.</p>
                
                <h3>What's Next?</h3>
                <ul>
                  ${userType == 'teacher' ? '''
                  <li>Add your students to the system</li>
                  <li>Create subjects for your class</li>
                  <li>Start marking attendance</li>
                  <li>Generate Excel reports anytime</li>
                  ''' : '''
                  <li>View your attendance records</li>
                  <li>Track your semester progress</li>
                  <li>Stay updated with your class</li>
                  '''}
                </ul>
                
                <p>If you have any questions or need assistance, feel free to reach out to our support team.</p>
                
                <p>Happy tracking! 📊</p>
                
                <p>Best regards,<br><strong>The Attendy Team</strong></p>
              </div>
              <div class="footer">
                <p>This is an automated email. Please do not reply to this message.</p>
                <p>&copy; 2026 Attendy App. All rights reserved.</p>
              </div>
            </div>
          </body>
          </html>
        ''';

      final sendReport = await send(message, smtpServer);
      print('✅ Welcome email sent: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('❌ Error sending welcome email: $e');
      return false;
    }
  }

  /// Send low attendance alert email
  Future<bool> sendLowAttendanceAlert({
    required String studentEmail,
    required String studentName,
    required String subjectName,
    required String attendancePercentage,
    required int presentDays,
    required int totalDays,
    required int absentDays,
  }) async {
    if (!isConfigured) {
      debugPrint('⚠️ Email not configured. Please set SMTP_EMAIL and SMTP_PASSWORD in .env file');
      return false;
    }
    
    try {
      final smtpServer = gmail(_senderEmail, _senderPassword);

      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(studentEmail)
        ..subject = '⚠️ Attendy - Low Attendance Alert'
        ..headers = {
          'X-Priority': '1',
          'X-Mailer': 'Attendy App',
        }
        ..html = '''
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { 
                font-family: Arial, sans-serif; 
                line-height: 1.6;
                color: #333;
              }
              .container {
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f9f9f9;
              }
              .header {
                background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                color: white;
                padding: 30px;
                text-align: center;
                border-radius: 10px 10px 0 0;
              }
              .content {
                background: white;
                padding: 30px;
                border-radius: 0 0 10px 10px;
              }
              .warning-box {
                background: #fff3cd;
                border-left: 4px solid #f5576c;
                padding: 15px;
                margin: 20px 0;
                border-radius: 5px;
              }
              .stats {
                display: flex;
                justify-content: space-around;
                margin: 20px 0;
                flex-wrap: wrap;
              }
              .stat-item {
                text-align: center;
                padding: 15px;
                background: #f8f9fa;
                border-radius: 8px;
                margin: 10px;
                min-width: 120px;
              }
              .stat-value {
                font-size: 32px;
                font-weight: bold;
                color: #f5576c;
              }
              .stat-label {
                font-size: 14px;
                color: #666;
                margin-top: 5px;
              }
              .footer {
                text-align: center;
                padding: 20px;
                font-size: 12px;
                color: #888;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>⚠️ Low Attendance Alert</h1>
              </div>
              <div class="content">
                <p>Dear <strong>$studentName</strong>,</p>
                
                <div class="warning-box">
                  <p><strong>⚠️ Attention Required!</strong></p>
                  <p>Your attendance in <strong>$subjectName</strong> has fallen below 75%.</p>
                </div>
                
                <h3>Your Attendance Summary:</h3>
                
                <div class="stats">
                  <div class="stat-item">
                    <div class="stat-value">$attendancePercentage%</div>
                    <div class="stat-label">Attendance</div>
                  </div>
                  <div class="stat-item">
                    <div class="stat-value">$presentDays</div>
                    <div class="stat-label">Present</div>
                  </div>
                  <div class="stat-item">
                    <div class="stat-value">$absentDays</div>
                    <div class="stat-label">Absent</div>
                  </div>
                  <div class="stat-item">
                    <div class="stat-value">$totalDays</div>
                    <div class="stat-label">Total Days</div>
                  </div>
                </div>
                
                <h3>⚠️ Important Notice:</h3>
                <ul>
                  <li>Minimum required attendance: <strong>75%</strong></li>
                  <li>Your current attendance: <strong>$attendancePercentage%</strong></li>
                  <li>Shortage: <strong>${(75.0 - double.parse(attendancePercentage)).toStringAsFixed(1)}%</strong></li>
                </ul>
                
                <h3>📌 Action Required:</h3>
                <ul>
                  <li>Please ensure regular class attendance</li>
                  <li>Contact your CR/Teacher if there are any discrepancies</li>
                  <li>Improve attendance to meet the minimum requirement</li>
                  <li>Falling below 75% may affect your eligibility for exams</li>
                </ul>
                
                <p><strong>Subject:</strong> $subjectName</p>
                
                <p>If you believe there is an error in your attendance record, please contact your Class Representative or Teacher immediately.</p>
                
                <p>Best regards,<br><strong>The Attendy Team</strong></p>
              </div>
              <div class="footer">
                <p>This is an automated email. Please do not reply to this message.</p>
                <p>&copy; 2026 Attendy App. All rights reserved.</p>
              </div>
            </div>
          </body>
          </html>
        ''';

      final sendReport = await send(message, smtpServer);
      print('✅ Low attendance alert sent to $studentEmail: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('❌ Error sending low attendance alert: $e');
      return false;
    }
  }
}
