# Setup Guide for Attendy

This guide will help you set up the Attendy app from scratch.

## Step 1: Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.10.7 or higher
  - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
- **Git**: For version control
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Account**: Free tier is sufficient
- **Gmail Account**: With 2-Step Verification enabled

## Step 2: Clone the Repository

```bash
git clone https://github.com/yourusername/attendy.git
cd attendy
```

## Step 3: Install Dependencies

```bash
flutter pub get
```

## Step 4: Firebase Setup

### 4.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `attendy` (or your preferred name)
4. Disable Google Analytics (optional)
5. Click "Create project"

### 4.2 Enable Firebase Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google Sign-In**
4. Add your support email

### 4.3 Create Realtime Database

1. Go to **Realtime Database** → **Create Database**
2. Choose a location (e.g., `asia-southeast1`)
3. Start in **Test mode** (we'll add rules later)

### 4.4 Configure Android App

1. In Firebase Console, click **Add app** → **Android**
2. Enter package name: `com.example.attendy`
3. Download `google-services.json`
4. Place it in `android/app/` directory

### 4.5 Update Firebase Configuration

1. Get your Firebase config from **Project Settings** → **General**
2. Note down:
   - API Key
   - App ID
   - Messaging Sender ID
   - Project ID
   - Database URL
   - Storage Bucket

## Step 5: Environment Configuration

### 5.1 Create .env File

Copy the example file:
```bash
cp .env.example .env
```

### 5.2 Gmail App Password Setup

1. Go to [Google Account Security](https://myaccount.google.com/security)
2. Enable **2-Step Verification** (if not already enabled)
3. Click **App passwords** (under "Signing in to Google")
4. Select:
   - App: **Mail**
   - Device: **Other** (enter "Attendy App")
5. Click **Generate**
6. Copy the 16-character password (remove spaces)

### 5.3 Update .env File

Open `.env` and update all values:

```env
# Email Configuration
SMTP_EMAIL=your-email@gmail.com
SMTP_PASSWORD=your16charpassword  # No spaces!
SMTP_SENDER_NAME=Attendy App

# Firebase Configuration
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_APP_ID=your-firebase-app-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com

# Android Signing (for release builds)
KEYSTORE_PASSWORD=your-keystore-password
KEY_PASSWORD=your-key-password
KEY_ALIAS=upload
```

## Step 6: Update Firebase Options

Create/Update `lib/firebase_options.dart`:

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    databaseURL: 'YOUR_DATABASE_URL',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
```

## Step 7: Configure Android Signing (Optional - For Release)

### 7.1 Generate Keystore

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 7.2 Update key.properties

The file `android/key.properties` should contain:
```properties
storePassword=your-password
keyPassword=your-password
keyAlias=upload
storeFile=upload-keystore.jks
```

## Step 8: Firebase Security Rules

Update your Firebase Realtime Database rules:

```json
{
  "rules": {
    ".read": false,
    ".write": false,
    "teachers": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "students": {
      "$teacherId": {
        ".read": "$teacherId === auth.uid",
        ".write": "$teacherId === auth.uid"
      }
    },
    "subjects": {
      "$teacherId": {
        ".read": "$teacherId === auth.uid",
        ".write": "$teacherId === auth.uid"
      }
    },
    "attendance": {
      "$teacherId": {
        ".read": "$teacherId === auth.uid",
        ".write": "$teacherId === auth.uid"
      }
    }
  }
}
```

## Step 9: Run the App

### Debug Mode
```bash
flutter run
```

### Release Mode
```bash
flutter run --release
```

### Build APK
```bash
flutter build apk --release
```

## Step 10: Verify Email Configuration

After running the app:
1. Register a new account
2. Check if you receive the verification email
3. If not, verify:
   - Gmail App Password is correct (no spaces)
   - 2-Step Verification is enabled
   - Email address is correct in `.env`

## Troubleshooting

### Common Issues

**1. Firebase not initializing**
- Check if `google-services.json` is in `android/app/`
- Verify package name matches in Firebase Console
- Run `flutter clean` and rebuild

**2. Email not sending**
- Verify Gmail App Password (regenerate if needed)
- Check if 2-Step Verification is enabled
- Ensure no spaces in password
- Check spam folder

**3. Build errors**
- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`
- Restart IDE

**4. Google Sign-In not working**
- Enable Google Sign-In in Firebase Console
- Add SHA-1 fingerprint in Firebase Console
- Rebuild the app

### Get SHA-1 Fingerprint

Debug SHA-1:
```bash
cd android
./gradlew signingReport
```

Release SHA-1 (if using keystore):
```bash
keytool -list -v -keystore upload-keystore.jks -alias upload
```

Add both SHA-1 fingerprints to Firebase Console:
**Project Settings** → **Your apps** → **Android app** → **Add fingerprint**

## Support

If you encounter any issues:
1. Check the [README.md](README.md) for general information
2. Review this setup guide thoroughly
3. Open an issue on GitHub with:
   - Error message
   - Steps to reproduce
   - Your environment (Flutter version, OS, etc.)

## Next Steps

After successful setup:
1. Create your teacher account
2. Add students and subjects
3. Start marking attendance
4. Test email notifications
5. Export attendance to Excel

Enjoy using Attendy! 🎉
