# 📘 Attendy - Complete Project Documentation

## 🌟 Project Overview
**Attendy** is a smart, comprehensive attendance management application built with **Flutter** and **Firebase**. It is designed for educational institutions to streamline the process of tracking student attendance, managing subjects, and generating reports. The app supports **offline operations**, **multi-university formats**, and **dual-role authentication**.

---

## 👥 Who Can Use Attendy?

### 1. 👨‍🏫 Class Representatives (CRs) / Teachers
*   **Primary Users**: The app is designed primarily for Class Representatives or Teachers who need to manage class attendance.
*   **Capabilities**:
    *   Create and manage student lists.
    *   Create and manage subjects.
    *   Mark daily attendance (Present/Absent).
    *   View attendance history.
    *   Export attendance reports to Excel.
    *   Work offline and sync data later.

### 2. 👨‍🎓 Students
*   **Secondary Users**: Students can log in to view their own status.
*   **Capabilities**:
    *   View their own profile.
    *   Check their attendance stats.
    *   Receive updates on their attendance status.

---

## 🚀 How to Use Attendy (User Guide)

### 1. Initial Setup & University Selection
When you first launch the app, you will be presented with a configuration screen:
*   **Select University Type**:
    *   **NTU (National Textile University)**: Enforces the strict roll number format `XX-NTU-YY-ZZZZ` (e.g., `23-NTU-CS-1272`).
    *   **Other University**: Allows any flexible alphanumeric roll number format (minimum 3 characters).
*   **Persistent Login**: Once logged in, you typically stay logged in until you explicitly sign out.

### 2. Authentication
*   **Login**: Enter your credentials (Email & Password).
*   **Sign Up**: New users can register by providing their details. 
*   **Forgot Password**: Secure password recovery via email OTP (6-digit code).
*   **Security**: All passwords are encrypted using SHA-256 hashing.

### 3. Dashboard Features
Once logged in, the dashboard serves as your central hub:
*   **Quick Actions**: Buttons to quickly navigate to Student Management, Subject Management, or View Reports.
*   **AI Features**: A "Coming Soon" section previewing future intelligent capabilities.

### 4. Managing Students
*   **Navigate to**: `Manage Students` screen.
*   **Add Student**: Click the floating `+` button.
    *   Enter Name, Roll Number, and Email.
    *   **Offline Mode**: If you are offline, the student will be saved locally and synced automatically when internet is restored.
*   **List View**: View all enrolled students sorted by roll number.

### 5. Managing Subjects
*   **Navigate to**: `Manage Subjects` screen.
*   **Add Subject**: Click the floating `+` button.
    *   Enter Subject Name and Code.
    *   Subjects are color-coded for easy visual distinction.
    *   **Offline Mode**: Works seamlessly without internet.

### 6. Marking Attendance
*   **Navigate to**: `Mark Attendance` screen.
*   **Process**:
    1.  Select a **Subject** from the dropdown.
    2.  Select the **Date** (defaults to today).
    3.  A list of students appears. Toggle the switch to mark **Present** (Green) or **Absent** (Red).
    4.  Click **Save Attendance**.
*   **Offline Capability**: 
    *   ✅ **Online**: Saves directly to Firebase.
    *   📴 **Offline**: Saves to local storage. An orange indicator confirms "Saved offline - will sync when online".
    *   🔄 **Auto-Sync**: Data automatically uploads the next time the app connects to the internet.

### 7. Reports & Analytics
*   **Navigate to**: `View Reports` screen.
*   **Excel Export**: Generate detailed `.xlsx` spreadsheets for any subject.
*   **Stats**: View total present/absent counts and percentage per student.
*   **Sharing**: Share the Excel file directly via WhatsApp, Email, or other apps.

---

## 🛠️ Key Technical Features

### 📡 Offline First Architecture
Attendy allows you to work completely offline.
*   **Queue System**: Operations (Add Student, Add Subject, Mark Attendance) are queued locally.
*   **Auto-Sync**: A background service monitors network connectivity and pushes changes to the cloud automatically.
*   **Visual Feedback**: Distinct UI indicators for online vs. offline actions.

### 🔒 Security
*   **SHA-256 Encryption**: User passwords are never stored in plain text.
*   **Email Verification**: Ensures valid user registration.
*   **Protected Routes**: Prevents unauthorized access to sensitive screens.

### 🎨 Modern UI/UX
*   **Material Design 3**: Clean, modern aesthetics.
*   **Responsive**: Works on various screen sizes.
*   **Animated**: Smooth transitions and splash screen animations.

---

## 🔮 Future AI Roadmap (Coming Soon)

We are actively working on integrating Artificial Intelligence to make Attendy smarter:

### 1. 📊 Predictive Analytics
*   **Risk Analysis**: Identify students at risk of falling below 75% attendance.
*   **Trend Forecasting**: Predict absence trends based on exams, weather, or seasonal data.

### 2. 🤖 Smart Automation
*   **Face Recognition**: Mark attendance simply by taking a class photo or individual selfies.
*   **Voice Commands**: "Mark Roll Number 23 Present" - hands-free operation.

### 3. 🧠 Intelligent Insights
*   **Behavioral Analysis**: Understand student engagement patterns.
*   **Smart Notifications**: Personalized reminders for teachers to mark attendance at habitual times.

### 4. 📄 Smart Document Processing
*   **Medical Certificate Scan**: Auto-scan and valid medical leave applications using OCR.
*   **Report Generation**: Natural Language Processing (NLP) to ask queries like "Show me list of students absent for 3 consecutive days".
