import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration helper
/// Loads and provides access to environment variables from .env file
class EnvConfig {
  static bool _initialized = false;

  /// Initialize environment configuration
  /// Call this in main.dart before runApp()
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
      print('✅ Environment configuration loaded');
    } catch (e) {
      print('⚠️ Could not load .env file: $e');
      print('⚠️ Using default/fallback values');
    }
  }

  /// Email Configuration
  static String get smtpEmail => dotenv.env['SMTP_EMAIL'] ?? '';
  static String get smtpPassword => dotenv.env['SMTP_PASSWORD'] ?? '';
  static String get smtpSenderName => dotenv.env['SMTP_SENDER_NAME'] ?? 'Attendy App';

  /// Firebase Configuration
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseDatabaseUrl => dotenv.env['FIREBASE_DATABASE_URL'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  /// Check if email is configured
  static bool get isEmailConfigured => 
      smtpEmail.isNotEmpty && 
      smtpPassword.isNotEmpty && 
      smtpEmail != 'your-email@gmail.com';

  /// Check if Firebase is configured
  static bool get isFirebaseConfigured => 
      firebaseApiKey.isNotEmpty && 
      firebaseApiKey != 'your-firebase-api-key';
}
