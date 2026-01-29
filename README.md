<div align="center">

# 🎓 Attendy - Smart Attendance Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.38.7-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.7-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-11.3.3-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/MALHI786/attendy?style=social)](https://github.com/MALHI786/attendy/stargazers)

<p align="center">
  <img src="https://via.placeholder.com/120x120/0088FF/FFFFFF?text=Attendy" alt="Attendy Logo" width="120" height="120">
</p>

### 📱 A powerful, feature-rich attendance management system built with Flutter

**Track attendance • Generate reports • Send alerts • Manage students**

[✨ Features](#-features) • [🚀 Quick Start](#-quick-start) • [📖 Documentation](#-documentation) • [🤝 Contributing](#-contributing)

---

</div>

## 📋 Table of Contents

- [About](#-about-the-project)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Environment Setup](#environment-setup)
- [Usage Guide](#-usage-guide)
- [Project Structure](#-project-structure)
- [Security](#-security)
- [API Reference](#-api-reference)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [Troubleshooting](#-troubleshooting)
- [Roadmap](#-roadmap)
- [License](#-license)
- [Contact](#-contact)

---

## 🎯 About The Project

**Attendy** is a comprehensive attendance management solution designed for educational institutions. Built with Flutter and Firebase, it offers a modern, intuitive interface for teachers to track student attendance, generate detailed reports, and automatically notify students with low attendance rates.

### 🌟 Why Attendy?

- **🚀 Modern & Fast**: Built with Flutter for smooth, native performance
- **🔐 Secure**: SHA-256 encryption, email verification, and environment-based secrets
- **📊 Insightful**: Excel reports with attendance analytics and visualizations
- **📧 Automated**: Smart email alerts for students below attendance threshold
- **🌙 Adaptive**: Dark mode with system preference detection
- **📱 Offline Ready**: SQLite local storage with cloud synchronization
- **🎨 Beautiful UI**: Material Design with smooth animations

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 👥 Authentication & Security
- **Dual Login System**
  - Teacher login via CNIC
  - Student login via Roll Number
- **Email Verification** with 6-digit OTP
- **SHA-256 Password Encryption**
- **Session Management** with secure tokens
- **Environment Variables** for sensitive data

### 📊 Attendance Management
- **Mark Attendance** for current or past dates
- **Quick Actions**: Mark all present/absent
- **Student Search** with instant filtering
- **Subject-wise Tracking**
- **Bulk Operations** for efficiency

### 📈 Reports & Analytics
- **Excel Export** with professional formatting
- **Attendance Statistics** (present/absent/percentage)
- **Visual Charts** with Syncfusion
- **Date Range Reports**
- **Student-wise Analysis**

</td>
<td width="50%">

### 📧 Email Notifications
- **Automated Alerts** for low attendance (<75%)
- **Custom Email Templates**
- **Batch Email Processing**
- **Email History Tracking**
- **Manual Email Override**

### 📱 WhatsApp Sharing
- **Share Absentees** directly to WhatsApp
- **Select Subject & Date** to fetch absentees
- **Custom Message Header** for personalization
- **Direct Phone Number** or choose contact
- **Formatted Message** with roll numbers

### 🎨 User Experience
- **🌙 Dark Mode** with system sync
- **📱 Responsive Design**
- **🎭 Smooth Animations**
- **🔍 Smart Search**
- **⚡ Fast Performance**

### 🔄 Data Management
- **Offline Mode** with SQLite
- **Auto Synchronization** with Firebase
- **Conflict Resolution** strategies
- **Data Validation** at multiple levels
- **Real-time Updates**

</td>
</tr>
</table>

---


## � Tech Stack

### Frontend
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

### Backend & Database
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^3.8.1 | Firebase initialization |
| `firebase_auth` | ^5.3.4 | User authentication |
| `firebase_database` | ^11.3.3 | Realtime database |
| `flutter_dotenv` | ^5.1.0 | Environment variables |
| `excel` | ^4.0.2 | Excel report generation |
| `mailer` | ^6.1.2 | Email functionality |
| `sqflite` | ^2.3.3+1 | Local database |
| `provider` | ^6.1.1 | State management |
| `shared_preferences` | ^2.2.2 | Local storage |
| `syncfusion_flutter_charts` | ^25.1.43 | Data visualization |

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** `>= 3.16.0` - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** `>= 3.2.0` (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** - [Download Git](https://git-scm.com/downloads)
- **Firebase Account** - [Create Account](https://console.firebase.google.com/)

Check your Flutter installation:
```bash
flutter doctor -v
```

---

### Installation

#### 1️⃣ Clone the Repository

```bash
git clone https://github.com/MALHI786/attendy.git
cd attendy
```

#### 2️⃣ Install Dependencies

```bash
flutter pub get
```

#### 3️⃣ Environment Setup

Create a `.env` file in the root directory:

```bash
# For Windows
copy .env.example .env

# For macOS/Linux
cp .env.example .env
```

Update `.env` with your credentials:

```env
# SMTP Configuration (Gmail)
SMTP_EMAIL=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Firebase Configuration
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_DATABASE_URL=your-database-url

# Android Keystore (for release builds)
KEYSTORE_PASSWORD=your-keystore-password
KEY_PASSWORD=your-key-password
KEY_ALIAS=your-key-alias
```

<details>
<summary>📧 How to get Gmail App Password</summary>

1. Go to [Google Account Settings](https://myaccount.google.com/apppasswords)
2. Select **Mail** and your device
3. Click **Generate**
4. Copy the 16-character password
5. Paste it in `.env` as `SMTP_PASSWORD` (remove spaces)

</details>

---

#### 4️⃣ Firebase Configuration

<details>
<summary>🔥 Firebase Setup Guide</summary>

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click **Add Project**
   - Enter project name: `Attendy`
   - Disable Google Analytics (optional)

2. **Add Android App**
   - Click **Add App** → **Android**
   - Package name: `com.example.attendy`
   - Download `google-services.json`
   - Place in `android/app/` directory

3. **Enable Authentication**
   - Go to **Authentication** → **Sign-in method**
   - Enable **Email/Password**

4. **Setup Realtime Database**
   - Go to **Realtime Database** → **Create Database**
   - Start in **test mode** (configure rules later)
   - Copy database URL to `.env`

5. **Update Firebase Options**
   - Open `lib/firebase_options.dart`
   - Update with your project credentials
   - Or use FlutterFire CLI:
     ```bash
     flutter pub global activate flutterfire_cli
     flutterfire configure
     ```

6. **Security Rules** (Recommended)
   ```json
   {
     "rules": {
       "users": {
         "$userId": {
           ".read": "$userId === auth.uid",
           ".write": "$userId === auth.uid"
         }
       },
       "students": {
         ".read": "auth != null",
         ".write": "auth != null"
       },
       "subjects": {
         ".read": "auth != null",
         ".write": "auth != null"
       },
       "attendance": {
         ".read": "auth != null",
         ".write": "auth != null"
       }
     }
   }
   ```

</details>

---

#### 5️⃣ Run the App

```bash
# Check connected devices
flutter devices

# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device-id>
```

---

## 📖 Usage Guide

### 👨‍🏫 For Teachers

<details>
<summary><b>Getting Started as a Teacher</b></summary>

1. **Register Your Account**
   - Launch the app
   - Select **"Teacher"** on user type screen
   - Fill in registration form:
     - CNIC (format: `xxxxx-xxxxxxx-x`)
     - Full Name
     - Email Address
     - Password (min 6 characters)
   - Click **Register**

2. **Verify Email**
   - Check your email inbox
   - Enter the 6-digit OTP code
   - Code expires in 10 minutes
   - Click **Verify**

3. **Dashboard Overview**
   - View total students, subjects, and attendance stats
   - Quick actions: Manage Students, Mark Attendance, View Reports
   - Access settings and profile

</details>

<details>
<summary><b>Managing Students</b></summary>

1. **Add New Student**
   - Tap **Student Management** from dashboard
   - Click **+** (Add) button
   - Enter student details:
     - Roll Number (unique identifier)
     - Email Address
   - Click **Save**

2. **Search & Filter**
   - Use search bar to find students by roll number or email
   - Results update in real-time

3. **Edit/Delete Students**
   - Tap on student card
   - Choose **Edit** or **Delete**
   - Confirm changes

</details>

<details>
<summary><b>Managing Subjects</b></summary>

1. **Add Subject**
   - Navigate to **Subject Management**
   - Click **+** button
   - Enter:
     - Subject Name
     - Credit Hours
   - Click **Save**

2. **View Subject Details**
   - Tap subject card to view attendance statistics
   - See total classes and attendance percentage

</details>

<details>
<summary><b>Marking Attendance</b></summary>

1. **Select Subject & Date**
   - Go to **Mark Attendance**
   - Choose subject from dropdown
   - Select date (current or past date)

2. **Mark Students**
   - **Quick Actions**:
     - Tap **Mark All Present** for 100% attendance
     - Tap **Mark All Absent** to mark all absent
   - **Individual**: Toggle student attendance status
   - Green = Present, Red = Absent

3. **Save Attendance**
   - Review marked attendance
   - Click **Save Attendance**
   - Confirmation message appears

</details>

<details>
<summary><b>Generating Reports</b></summary>

1. **Navigate to Reports**
   - Tap **View Reports** from dashboard

2. **Select Subject**
   - Choose subject for report generation
   - View attendance summary

3. **Export to Excel**
   - Click **Export to Excel**
   - File is generated with:
     - Student list
     - Date-wise attendance
     - Attendance percentage
     - Statistical summary
   - Share or download the file

</details>

<details>
<summary><b>Sending Email Alerts</b></summary>

1. **Automatic Detection**
   - System identifies students with <75% attendance

2. **Review & Send**
   - Go to **Dashboard** → **Send Email Notifications**
   - Review list of students below threshold
   - Adjust threshold if needed
   - Click **Send Emails**

3. **Track Email History**
   - View sent emails in history
   - Check delivery status

</details>

<details>
<summary><b>Sharing Absentees via WhatsApp</b></summary>

1. **Open WhatsApp Share**
   - Go to **Dashboard** → **WhatsApp Share**

2. **Select Subject & Date**
   - Choose the subject from dropdown
   - Select the date for which you want absentees
   - Optionally add a custom message header

3. **Fetch Absentees**
   - Click **Fetch Absentees** button
   - View the list of absent students

4. **Share to WhatsApp**
   - Click **Share to WhatsApp**
   - Preview the formatted message
   - Optionally enter a phone number
   - Click **Send** to open WhatsApp with message

5. **Send the Message**
   - WhatsApp opens with pre-filled message
   - Choose contact or group to send
   - Message includes: Subject, Date, Roll Numbers

</details>

---

### 👨‍🎓 For Students

<details>
<summary><b>Student Login & Dashboard</b></summary>

1. **Login**
   - Select **"Student"** on user type screen
   - Enter your Roll Number
   - Enter Password (set by teacher or yourself)
   - Click **Login**

2. **First-Time Setup**
   - If first login, you'll be prompted to:
     - Set your password
     - Verify your email

3. **View Attendance**
   - Dashboard shows:
     - Overall attendance percentage
     - Subject-wise breakdown
     - Recent attendance records
   - Check which subjects need attention

4. **Receive Alerts**
   - Get email notifications if attendance falls below 75%
   - Check email for detailed information

</details>

---

## � Project Structure

```
attendy/
├── android/                      # Android native code
│   ├── app/
│   │   ├── build.gradle         # Android build configuration
│   │   └── google-services.json # Firebase config (not in git)
│   └── key.properties           # Keystore credentials (not in git)
├── ios/                          # iOS native code
├── lib/                          # Main application code
│   ├── models/                   # Data models
│   │   ├── student.dart         # Student model
│   │   ├── subject.dart         # Subject model
│   │   └── teacher.dart         # Teacher model
│   ├── screens/                  # UI screens
│   │   ├── user_type_screen.dart
│   │   ├── student_login_screen.dart
│   │   ├── teacher_login_screen.dart
│   │   ├── email_verification_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── student_management_screen.dart
│   │   ├── subject_management_screen.dart
│   │   ├── attendance_screen.dart
│   │   └── view_reports_screen.dart
│   ├── services/                 # Business logic & services
│   │   ├── env_config.dart      # Environment variable management
│   │   ├── firebase_service.dart # Firebase operations
│   │   ├── email_service.dart   # Email functionality
│   │   ├── excel_service.dart   # Excel report generation
│   │   └── attendance_email_service.dart
│   ├── utils/                    # Utility functions
│   │   └── validators.dart      # Form validation
│   ├── firebase_options.dart    # Firebase configuration
│   └── main.dart                # App entry point
├── assets/                       # Static assets
│   └── icon/
│       └── logo.png             # App logo
├── .env                         # Environment variables (not in git)
├── .env.example                 # Environment template
├── .gitignore                   # Git ignore rules
├── pubspec.yaml                 # Package dependencies
└── README.md                    # This file
```

---

## 🔐 Security

Security is a top priority in Attendy. Here's how we protect your data:

### 🛡️ Security Features

| Feature | Implementation | Description |
|---------|---------------|-------------|
| **Password Encryption** | SHA-256 Hashing | All passwords are hashed before storage |
| **Email Verification** | 6-digit OTP | Mandatory verification for all accounts |
| **OTP Expiration** | 10 minutes | Time-limited verification codes |
| **Session Management** | SharedPreferences | Secure session tokens |
| **Environment Variables** | flutter_dotenv | No hardcoded credentials |
| **Firebase Rules** | Database security | Role-based access control |
| **Data Validation** | Multi-level | Client and server-side validation |

### 🔒 Environment Configuration

The app uses `flutter_dotenv` for secure credential management:

```dart
// lib/services/env_config.dart
class EnvConfig {
  static String get smtpEmail => dotenv.env['SMTP_EMAIL'] ?? '';
  static String get smtpPassword => dotenv.env['SMTP_PASSWORD'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  // ... more configurations
}
```

**Files Structure:**
- `.env` - Contains actual secrets (❌ excluded from git)
- `.env.example` - Template with placeholders (✅ safe to commit)
- `lib/services/env_config.dart` - Centralized configuration

### 🔥 Firebase Security Rules

```json
{
  "rules": {
    "users": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    },
    "students": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "subjects": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "attendance": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

### 📝 Best Practices

- ✅ Never commit `.env` file
- ✅ Use strong passwords (min 6 characters)
- ✅ Enable two-factor authentication on Firebase
- ✅ Regularly update dependencies
- ✅ Review Firebase security rules
- ✅ Use HTTPS for all network requests

---

## 🚢 Deployment

### Android Deployment

#### Debug Build
```bash
flutter build apk --debug
```

#### Release Build
```bash
# Generate release APK
flutter build apk --release

# Generate App Bundle (recommended for Play Store)
flutter build appbundle --release
```

**Output locations:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

#### Signing Configuration

Create `android/key.properties`:
```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=your-key-alias
storeFile=/path/to/keystore.jks
```

### iOS Deployment

```bash
flutter build ios --release
```

### Web Deployment

```bash
flutter build web --release
```

---
## 🤝 Contributing

Contributions make the open-source community an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**! 🎉

### How to Contribute

1. **Fork the Project**
   ```bash
   # Click the 'Fork' button at the top right of this page
   ```

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/your-username/attendy.git
   cd attendy
   ```

3. **Create a Feature Branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```

4. **Make Your Changes**
   - Write clean, documented code
   - Follow Dart/Flutter style guidelines
   - Add comments for complex logic
   - Update documentation if needed

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Add some AmazingFeature"
   ```

6. **Push to Your Branch**
   ```bash
   git push origin feature/AmazingFeature
   ```

7. **Open a Pull Request**
   - Go to the original repository
   - Click **New Pull Request**
   - Describe your changes
   - Submit for review

### Development Guidelines

#### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Keep functions small and focused
- Add dartdoc comments for public APIs

#### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

#### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Check for outdated packages
flutter pub outdated
```

### 🐛 Reporting Bugs

Found a bug? Please create an issue with:
- **Title**: Clear, descriptive title
- **Description**: Detailed description of the bug
- **Steps to Reproduce**: Step-by-step instructions
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Screenshots**: If applicable
- **Environment**: Flutter version, device, OS

### 💡 Feature Requests

Have an idea? We'd love to hear it!
- Open an issue with the `enhancement` label
- Describe the feature and its benefits
- Explain use cases

---

## 🐛 Troubleshooting

### Common Issues & Solutions

<details>
<summary><b>🔥 Firebase Connection Failed</b></summary>

**Problem:** App can't connect to Firebase

**Solutions:**
1. Verify `google-services.json` is in `android/app/`
2. Check Firebase project configuration
3. Ensure internet connection is active
4. Verify Firebase Database URL in `.env`
5. Check Firebase console for project status

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

</details>

<details>
<summary><b>📧 Emails Not Sending</b></summary>

**Problem:** Email alerts not working

**Solutions:**
1. Verify SMTP credentials in `.env`
2. Check Gmail App Password is correct (no spaces)
3. Ensure "Less secure app access" is enabled (if using regular password)
4. Check email quota limits
5. Verify internet connection
6. Check spam folder for test emails

```dart
// Test SMTP configuration
print('SMTP Email: ${EnvConfig.smtpEmail}');
print('SMTP Password: ${EnvConfig.smtpPassword.isNotEmpty ? "Set" : "Missing"}');
```

</details>

<details>
<summary><b>🏗️ Build Errors</b></summary>

**Problem:** Build fails with errors

**Solutions:**
```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Clear gradle cache (Android)
cd android
./gradlew clean
cd ..

# Rebuild
flutter run
```

**Common error fixes:**
- **Gradle sync failed**: Update `android/build.gradle` Gradle version
- **Dependency conflict**: Run `flutter pub outdated` and update
- **SDK version mismatch**: Check `minSdkVersion` in `android/app/build.gradle`

</details>

<details>
<summary><b>🔑 Environment Variables Not Loading</b></summary>

**Problem:** App can't read `.env` file

**Solutions:**
1. Ensure `.env` file exists in project root
2. Check file name is exactly `.env` (not `.env.txt`)
3. Verify `flutter_dotenv` is in `pubspec.yaml`
4. Add `.env` to `pubspec.yaml` assets:
   ```yaml
   flutter:
     assets:
       - .env
   ```
5. Run `flutter pub get` after adding
6. Restart app completely

</details>

<details>
<summary><b>📱 App Crashes on Startup</b></summary>

**Problem:** App crashes immediately after launch

**Solutions:**
1. Check Firebase initialization in `main.dart`
2. Verify all required environment variables are set
3. Check for null safety issues
4. Review logs:
   ```bash
   flutter logs
   ```
5. Run in debug mode for detailed error:
   ```bash
   flutter run --debug
   ```

</details>

<details>
<summary><b>💾 Data Not Syncing</b></summary>

**Problem:** Local data not syncing with Firebase

**Solutions:**
1. Check internet connection
2. Verify Firebase Security Rules allow write access
3. Check authentication status
4. Review Firebase console for denied requests
5. Clear app data and re-login

</details>

### 🔍 Debug Commands

```bash
# Check Flutter setup
flutter doctor -v

# Analyze code for issues
flutter analyze

# Check for outdated packages
flutter pub outdated

# Clean everything
flutter clean && flutter pub get

# Run tests
flutter test

# Build with verbose output
flutter run -v

# Check connected devices
flutter devices

# Generate build size analysis
flutter build apk --analyze-size
```

### 📞 Still Having Issues?

If you're still experiencing problems:

1. **Check Existing Issues**: [GitHub Issues](https://github.com/MALHI786/attendy/issues)
2. **Create New Issue**: Include error logs, screenshots, and steps to reproduce
3. **Contact Developer**: salmanmalhig@gmail.com

---
## 🗺️ Roadmap

Here's what's planned for future releases:

### Version 2.0 (Q2 2026)
- [ ] 📸 **Face Recognition Attendance** - AI-powered facial recognition
- [ ] 🔔 **Push Notifications** - Real-time alerts via FCM
- [ ] 🌍 **Multi-language Support** - Support for Urdu, Arabic, Spanish
- [ ] 📊 **Advanced Analytics Dashboard** - Charts, trends, predictions
- [ ] 👨‍👩‍👧 **Parent Portal** - Parents can view their child's attendance

### Version 2.5 (Q4 2026)
- [ ] 🤖 **AI Attendance Predictions** - ML-based attendance forecasting
- [ ] 📱 **Mobile App for Parents** - Dedicated parent app
- [ ] 🎓 **LMS Integration** - Connect with learning management systems
- [ ] 📷 **QR Code Attendance** - Quick check-in via QR codes
- [ ] 📈 **Performance Reports** - Correlation between attendance & grades

### Version 3.0 (2027)
- [ ] 🌐 **Web Dashboard** - Full web application
- [ ] 💻 **Desktop Apps** - Windows, macOS, Linux applications
- [ ] 🔗 **API Integration** - RESTful API for third-party integrations
- [ ] 🎯 **Gamification** - Rewards for good attendance
- [ ] 📊 **Business Intelligence** - Advanced reporting for institutions

### Community Requested Features
- [ ] Biometric authentication
- [ ] Offline Excel generation
- [ ] Custom attendance thresholds per subject
- [ ] Bulk student import via CSV
- [ ] Academic calendar integration
- [ ] Parent-teacher communication

**Want to see a feature?** [Open a feature request](https://github.com/MALHI786/attendy/issues/new?labels=enhancement)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024-2026 Salman Malhi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📞 Contact & Support

<div align="center">

### 👨‍💻 Developer

**Salman Malhi**

[![Email](https://img.shields.io/badge/Email-salmanmalhig%40gmail.com-red?style=for-the-badge&logo=gmail&logoColor=white)](mailto:salmanmalhig@gmail.com)
[![GitHub](https://img.shields.io/badge/GitHub-MALHI786-181717?style=for-the-badge&logo=github)](https://github.com/MALHI786)
[![Instagram](https://img.shields.io/badge/Instagram-@m__salman__malhi-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/m_salman_malhi)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-%2B92%20342%205844921-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://wa.me/923425844921)

### 💬 Get Help

- 🐛 **Bug Reports**: [Create an Issue](https://github.com/MALHI786/attendy/issues/new?labels=bug)
- 💡 **Feature Requests**: [Request Feature](https://github.com/MALHI786/attendy/issues/new?labels=enhancement)
- 📚 **Documentation**: [View Docs](https://github.com/MALHI786/attendy/wiki)
- 💬 **Discussions**: [Join Discussion](https://github.com/MALHI786/attendy/discussions)

</div>

---

## 🙏 Acknowledgments

Special thanks to:

- **[Flutter Team](https://flutter.dev)** - For the amazing cross-platform framework
- **[Firebase](https://firebase.google.com)** - For reliable backend services
- **[Syncfusion](https://www.syncfusion.com/flutter-widgets)** - For beautiful chart components
- **[Material Design](https://material.io)** - For design guidelines and inspiration
- **Open Source Community** - For countless helpful packages and tools
- **Contributors** - Everyone who has contributed to making this project better
- **Testers & Users** - For valuable feedback and bug reports

### 🌟 Built With Love Using

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
</p>

---

## ⭐ Show Your Support

If you found this project helpful, please consider:

- ⭐ **Starring the repository** on GitHub
- 🔄 **Sharing** with others who might benefit
- 🐛 **Reporting bugs** to help improve the app
- 💡 **Suggesting features** for future releases
- 🤝 **Contributing** code or documentation

<div align="center">

### 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/MALHI786/attendy?style=social)
![GitHub forks](https://img.shields.io/github/forks/MALHI786/attendy?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/MALHI786/attendy?style=social)
![GitHub issues](https://img.shields.io/github/issues/MALHI786/attendy)
![GitHub pull requests](https://img.shields.io/github/issues-pr/MALHI786/attendy)

---

<p align="center">
  <b>Made with ❤️ by Salman Malhi</b>
</p>

<p align="center">
  <i>If you have any questions or feedback, feel free to reach out!</i>
</p>

<p align="center">
  <sub>© 2024-2026 Attendy. All rights reserved.</sub>
</p>

</div>
