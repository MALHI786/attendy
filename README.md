# 🎓 Attendy - Smart Attendance Management System

![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue)
![Dart](https://img.shields.io/badge/Dart-3.2.0-blue)
![Firebase](https://img.shields.io/badge/Firebase-11.3.3-orange)
![License](https://img.shields.io/badge/License-MIT-green)

<div align="center">
  
  ![Attendy Banner](https://via.placeholder.com/800x200/0088FF/FFFFFF?text=Attendy+Smart+Attendance+Management)
  
  **A comprehensive Flutter-based attendance management system with dual authentication, offline sync, dark mode, and automated email alerts.**
  
  [Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Contributing](#-contributing)
  
</div>

## ✨ Enhanced Features

### ✅ Core Features
- **👥 Dual Authentication**: Separate login for Teachers (CNIC-based) and Students (Roll Number-based)
- **📧 Email Verification**: 6-digit OTP system for secure account activation
- **🔒 SHA-256 Encryption**: Industry-standard password hashing
- **📊 Excel Export**: Professional Excel reports with formatting
- **📅 Past Date Support**: Mark attendance for any date
- **🔍 Quick Search**: Instant student/subject search functionality

### ✨ Newly Added Features
- **🌙 Dark Mode**: Complete dark theme with system preference detection
- **📱 Offline Sync**: Local SQLite database with automatic cloud synchronization
- **📧 Email Alerts**: Automated notifications for low-attendance students
- **🎨 Enhanced UI**: Beautiful gradient designs with smooth animations
- **📊 Advanced Analytics**: Charts and graphs for attendance visualization
- **⚡ Quick Actions**: Mark all present/absent with single tap

## 📸 Screenshots

| Light Mode | Dark Mode | Email Alerts |
|------------|-----------|--------------|
| ![Light](https://via.placeholder.com/200x400/FFFFFF/000000?text=Light+Mode) | ![Dark](https://via.placeholder.com/200x400/1A1A1A/FFFFFF?text=Dark+Mode) | ![Email](https://via.placeholder.com/200x400/0088FF/FFFFFF?text=Email+Alerts) |

| Dashboard | Attendance | Reports |
|-----------|------------|---------|
| ![Dashboard](https://via.placeholder.com/200x400/FFFFFF/000000?text=Dashboard) | ![Attendance](https://via.placeholder.com/200x400/FFFFFF/000000?text=Attendance) | ![Reports](https://via.placeholder.com/200x400/FFFFFF/000000?text=Reports) |

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (>= 3.16.0)
- Dart SDK (>= 3.2.0)
- Firebase account
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/attendy.git
   cd attendy
Install dependencies

bash
flutter pub get
Configure Firebase

Create project at Firebase Console

Add Android/iOS app

Download config files:

Android: google-services.json → android/app/

iOS: GoogleService-Info.plist → ios/Runner/

Enable Authentication & Realtime Database

Set up Cloud Functions for email alerts

Run the app

bash
flutter run
📱 Features in Detail
🌙 Dark Mode
Automatic system theme detection

Manual toggle option

Consistent theming across all screens

Smooth transition animations

📱 Offline Mode
Local Storage: SQLite database for offline operations

Auto-Sync: Automatic synchronization when back online

Conflict Resolution: Smart merge strategies for data conflicts

Progress Tracking: Visual indicators for sync status

📧 Email Alerts System
Automatic Detection: Identifies students below attendance threshold (default: 75%)

Batch Processing: Send emails to multiple students simultaneously

Custom Templates: Professional email templates

Email History: Track all sent communications

Manual Override: Select specific students for alerts

📊 Advanced Analytics
Visual Charts: Pie and bar charts for attendance patterns

Statistics: Present/Absent counts with percentages

Trend Analysis: Attendance trends over time

Export Options: Excel, PDF, and CSV formats

🏗️ Architecture
text
lib/
├── models/          # Data models (Student, Subject, Attendance)
├── screens/         # UI Screens
├── services/        # Business logic (Firebase, Email, Offline)
├── utils/           # Utilities & Constants
└── widgets/         # Reusable UI components
🔧 Configuration
Firebase Setup
Realtime Database Rules:

json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
Cloud Functions (for email alerts):

javascript
exports.sendAttendanceAlert = functions.firestore
  .document('attendance/{docId}')
  .onUpdate(async (change, context) => {
    // Email sending logic
  });
App Configuration
Edit lib/utils/constants.dart:

dart
class AppConstants {
  static const double attendanceThreshold = 75.0;
  static const String appName = 'Attendy';
  static const String supportEmail = 'salmanmalhig@gmail.com';
  // ... other constants
}
📖 Usage Guide
For Teachers
Register: CNIC, Name, Email, Password

Verify Email: 6-digit OTP verification

Add Students: Roll numbers and emails

Create Subjects: Name and credit hours

Mark Attendance: Daily or past dates

Send Alerts: Email low-attendance students

Generate Reports: Excel export with analytics

For Students
Login: Roll number and password

View Attendance: Subject-wise statistics

Check Progress: Attendance percentage

Receive Alerts: Email notifications

🔐 Security Features
SHA-256 password hashing

Email verification for all accounts

Session management with secure tokens

Firebase Security Rules implementation

Data validation at multiple levels

📦 Dependencies
Key packages used:

Package	Version	Purpose
firebase_core	^3.8.1	Firebase initialization
firebase_auth	^5.3.4	Authentication
sqflite	^2.3.3+1	Offline database
provider	^6.1.1	State management
syncfusion_flutter_charts	^25.1.43	Data visualization
flutter_email_sender	^6.2.1	Email alerts
See full pubspec.yaml for complete list

🚀 Deployment
Android
bash
flutter build apk --release
# or
flutter build appbundle --release
iOS
bash
flutter build ios --release
🤝 Contributing
We love contributions! Here's how:

Fork the repository

Create your feature branch (git checkout -b feature/AmazingFeature)

Commit your changes (git commit -m 'Add some AmazingFeature')

Push to the branch (git push origin feature/AmazingFeature)

Open a Pull Request

Development Guidelines
Follow Dart/Flutter style guide

Add comments for complex logic

Write tests for new features

Update documentation accordingly

🐛 Troubleshooting
Common Issues
Firebase connection failed

Verify google-services.json placement

Check internet connection

Confirm Firebase project settings

Build errors

bash
flutter clean
flutter pub get
flutter run
Email not sending

Check Cloud Functions deployment

Verify SMTP configuration

Check email quota limits

Debug Commands
bash
# Check dependencies
flutter pub outdated

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate build report
flutter build apk --analyze-size
📄 License
Distributed under MIT License. See LICENSE for more information.

📞 Contact & Support
Developer: Salman Malhi

Email: salmanmalhig@gmail.com

Instagram: @m_salman_malhi

WhatsApp: +92 342 5844921

Issue Tracker: GitHub Issues

🙏 Acknowledgments
Flutter team for the amazing framework

Firebase for backend services

Material Design for UI inspiration

All contributors and testers

🔮 Roadmap
Face recognition attendance

Push notifications

Multi-language support

Parent portal

Mobile app for parents

AI-powered predictions

Integration with LMS systems

<div align="center">
Made with ❤️ by Salman Malhi

⭐ Star this repo on GitHub

</div>
