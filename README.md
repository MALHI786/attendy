# Attendy - Smart Attendance Management App

A comprehensive Flutter-based attendance management system for educational institutions, featuring dual authentication (Teacher/Student), email verification, Excel reporting, and Firebase integration.

---

## 🚀 Features

### Authentication & Security
- **Dual Login System**: Separate authentication flows for Teachers (CNIC-based) and Students (Roll Number-based)
- **Email Verification**: 6-digit OTP verification for account security
- **Password Reset**: Secure password recovery via email verification
- **SHA-256 Encryption**: Secure password hashing for user protection

### Attendance Management
- **Smart Attendance Marking**: Mark attendance with present/absent buttons
- **Past Date Support**: Ability to mark attendance for previous dates
- **Quick Actions**: Mark all present/absent with one tap
- **Real-time Updates**: Instant sync with Firebase Realtime Database
- **Attendance History**: View complete attendance records per subject

### Student & Subject Management
- **Duplicate Prevention**: Automatic validation to prevent duplicate students or subjects
- **Search Functionality**: Quick search through student lists
- **Semester Management**: Editable semester numbers from the dashboard
- **Color-Coded Subjects**: Visual distinction between different subjects

### Reports & Analytics
- **Excel Export**: Generate downloadable Excel reports per subject
- **Attendance Statistics**: View present/absent counts and percentages
- **Styled Reports**: Professional Excel formatting with color-coded data
- **Share & Download**: Easy sharing and downloading of reports

### User Experience
- **Material Design 3**: Modern, beautiful UI with gradient backgrounds
- **Animated Splash Screen**: Smooth app entry with fade/scale animations
- **Responsive Design**: Optimized for various screen sizes
- **Session Management**: Persistent login using SharedPreferences

---

## 📱 App Icon

The app uses a modern, minimalist 3D icon with the following design specification:

**Icon Prompt**: 
```
A high-quality, modern, minimalist 3D app icon for an attendance app named 'Attendy', 
vibrant blue and white theme, soft shadows, 1024x1024 PNG, white background
```

**Design Elements**:
- Vibrant blue primary color representing professionalism and trust
- White accents for clarity and simplicity
- 3D effect with soft shadows for modern aesthetic
- Minimalist design for easy recognition
- Standard 1024x1024 PNG format for cross-platform compatibility

**To Generate the Icon**:
1. Use AI image generators (DALL-E, Midjourney, Stable Diffusion) with the above prompt
2. Or use design tools (Figma, Adobe Illustrator) for custom creation
3. Place the generated icon in appropriate directories:
   - Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
4. Use `flutter_launcher_icons` package for automated icon generation across all platforms

---

## 🛠️ Technology Stack

### Frontend
- **Flutter SDK**: ^3.10.7
- **Dart**: Language for Flutter development
- **Material Design 3**: Modern UI components

### Backend & Database
- **Firebase Realtime Database**: Real-time data synchronization
- **Firebase Authentication**: User authentication services
- **Firebase Core**: Firebase SDK integration

### Key Packages
- `firebase_core`: ^3.8.1 - Firebase initialization
- `firebase_database`: ^11.3.3 - Realtime database
- `firebase_auth`: ^5.3.4 - Authentication
- `excel`: ^4.0.6 - Excel file generation
- `path_provider`: ^2.1.5 - File system access
- `share_plus`: ^10.1.4 - File sharing functionality
- `open_filex`: ^4.5.0 - Open files in external apps
- `crypto`: ^3.0.6 - Password hashing (SHA-256)
- `shared_preferences`: ^2.3.3 - Local data persistence
- `intl`: ^0.19.0 - Date formatting

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point with splash screen
├── firebase_options.dart              # Firebase configuration
├── models/
│   ├── student.dart                   # Student data model
│   ├── subject.dart                   # Subject data model
│   └── teacher.dart                   # Teacher data model
├── screens/
│   ├── user_type_screen.dart          # Student/Teacher selection
│   ├── student_login_screen.dart      # Student authentication
│   ├── teacher_login_screen.dart      # Teacher authentication
│   ├── email_verification_screen.dart # OTP verification
│   ├── forgot_password_screen.dart    # Password recovery
│   ├── dashboard_screen.dart          # Main dashboard
│   ├── student_management_screen.dart # Manage students
│   ├── subject_management_screen.dart # Manage subjects
│   ├── attendance_screen.dart         # Mark attendance
│   └── view_reports_screen.dart       # View and export reports
├── services/
│   ├── firebase_service.dart          # Firebase CRUD operations
│   ├── excel_service.dart             # Excel report generation
│   └── auth_service.dart              # Email verification service
└── utils/
    └── validators.dart                # Form validation functions
```

---

## 🚦 Getting Started

### Prerequisites
- Flutter SDK (^3.10.7)
- Dart SDK
- Android Studio / VS Code
- Firebase account with a configured project
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd attendy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android app to your Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Enable Firebase Realtime Database and Authentication
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📖 User Guide

### For Teachers

1. **First-Time Setup**
   - Select "Teacher" on the user type screen
   - Enter your CNIC (format: xxxxx-xxxxxxx-x), name, and email
   - Verify your email with the 6-digit code sent to your inbox
   - Set a strong password

2. **Managing Students**
   - From dashboard, tap "Student Management"
   - Add students with roll numbers and emails
   - Search for specific students using the search bar
   - System prevents duplicate roll numbers

3. **Managing Subjects**
   - Tap "Subject Management" from dashboard
   - Add subjects with names and credit hours
   - View attendance count for each subject
   - System prevents duplicate subject names

4. **Marking Attendance**
   - Select "Mark Attendance" from dashboard
   - Choose subject and date (including past dates)
   - Use quick actions or mark individually
   - Tap "Save Attendance" to sync with database

5. **Viewing Reports**
   - Navigate to "View Reports"
   - Select a subject to generate Excel report
   - Download or share the report
   - Reports include attendance percentages and statistics

### For Students

1. **Login**
   - Select "Student" on user type screen
   - Enter your roll number
   - For first-time login, provide email and password
   - Verify your email

2. **View Your Data**
   - Access dashboard to see attendance statistics
   - Check attendance records by subject
   - View your semester information

---

## 🔐 Security Features

- **Password Hashing**: SHA-256 encryption for all passwords
- **Email Verification**: Mandatory email verification for account activation
- **OTP Expiration**: Verification codes expire after 10 minutes
- **Duplicate Prevention**: Database-level validation against duplicates
- **Session Management**: Secure session handling with SharedPreferences
- **Firebase Security Rules**: Recommended rules for database protection

### Recommended Firebase Rules

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

---

## 🎨 Customization

### Theme Colors
Update colors in `main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue,  // Change primary color
  brightness: Brightness.light,
),
```

### App Name
Update in:
- `android/app/src/main/AndroidManifest.xml` - android:label
- `ios/Runner/Info.plist` - CFBundleName

### Firebase Configuration
Update `lib/firebase_options.dart` with your project credentials

---

## 🐛 Troubleshooting

### Build Issues
```bash
flutter clean
flutter pub get
flutter run
```

### Firebase Connection Issues
- Verify `google-services.json` is in correct location
- Check Firebase project settings
- Ensure Firebase Database is in "Locked mode" or has appropriate rules

### Dependency Conflicts
```bash
flutter pub outdated
flutter pub upgrade
```

---

## 📊 Database Structure

```
Firebase Realtime Database
├── users/
│   └── {crRollNumber}/
│       ├── userType: "teacher" | "student"
│       ├── cnic: string (teachers only)
│       ├── name: string
│       ├── email: string
│       ├── password: string (hashed)
│       ├── emailVerified: boolean
│       └── semester: number
├── students/
│   └── {crRollNumber}/
│       └── {studentId}/
│           ├── rollNumber: string
│           ├── email: string
│           └── createdAt: timestamp
├── subjects/
│   └── {crRollNumber}/
│       └── {subjectId}/
│           ├── name: string
│           ├── creditHours: number
│           └── createdAt: timestamp
└── attendance/
    └── {crRollNumber}/
        └── {subjectId}/
            └── {date}/
                └── {studentId}: boolean
```

---

## 🤖 AI Features (Future Enhancements)

See [AI_FEATURES.md](AI_FEATURES.md) for detailed documentation on potential AI integrations including:
- Predictive attendance analytics
- Face recognition attendance
- Smart notifications
- Anomaly detection
- AI chatbot assistant
- And much more...

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Material Design for UI guidelines
- Community packages that made this possible

---

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Email: support@attendy.com

---

## 🔄 Version History

### v1.0.0 (Current)
- Initial release
- Dual authentication system
- Attendance management
- Excel report generation
- Email verification
- Password recovery
- Past date attendance support

---

## 🚀 Future Roadmap

- [ ] Multi-language support
- [ ] Dark mode
- [ ] Offline mode with sync
- [ ] Push notifications
- [ ] AI-powered features (see AI_FEATURES.md)
- [ ] iOS support improvements
- [ ] Web version
- [ ] Desktop applications

---

**Made with ❤️ using Flutter**
