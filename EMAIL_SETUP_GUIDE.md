# Email Configuration Guide for Attendy

## Setting Up Gmail to Send Emails

### Step 1: Create a Gmail Account (if needed)
Use a dedicated Gmail account for the app (e.g., `attendy.noreply@gmail.com`)

### Step 2: Enable 2-Step Verification
1. Go to [Google Account Settings](https://myaccount.google.com/)
2. Click on **Security** in the left menu
3. Under "Signing in to Google", click **2-Step Verification**
4. Follow the prompts to enable it

### Step 3: Generate App Password
1. Go back to **Security** settings
2. Under "Signing in to Google", click **App passwords**
3. Select:
   - **App**: Mail
   - **Device**: Other (custom name) → Type "Attendy App"
4. Click **Generate**
5. **Copy the 16-character password** (you won't see it again)

### Step 4: Update Email Service Configuration
Open `lib/services/email_service.dart` and update:

```dart
static const String _senderEmail = 'your-email@gmail.com'; // Your Gmail address
static const String _senderPassword = 'your-16-char-app-password'; // The app password
```

### Step 5: Test Email Sending
Run the app and try:
- Student registration with email verification
- Teacher registration with email verification  
- Forgot password flow

You should receive actual emails in the Gmail inbox!

---

## Alternative: Using Other Email Providers

### Outlook/Office 365
```dart
final smtpServer = SmtpServer(
  'smtp.office365.com',
  port: 587,
  username: 'your-email@outlook.com',
  password: 'your-password',
);
```

### Yahoo Mail
```dart
final smtpServer = SmtpServer(
  'smtp.mail.yahoo.com',
  port: 465,
  username: 'your-email@yahoo.com',
  password: 'your-app-password',
  ssl: true,
);
```

### Custom SMTP Server
```dart
final smtpServer = SmtpServer(
  'smtp.yourdomain.com',
  port: 587,
  username: 'noreply@yourdomain.com',
  password: 'your-password',
);
```

---

## Production Best Practices

### 1. Environment Variables
**Never commit credentials to Git!** Use environment variables:

Create `.env` file (add to `.gitignore`):
```
SENDER_EMAIL=your-email@gmail.com
SENDER_PASSWORD=your-app-password
```

Use `flutter_dotenv` package:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Load in `email_service.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static String get _senderEmail => dotenv.env['SENDER_EMAIL']!;
static String get _senderPassword => dotenv.env['SENDER_PASSWORD']!;
```

### 2. Use Firebase Cloud Functions (Recommended)
For better security, send emails from a backend:

**Firebase Function (Node.js):**
```javascript
const functions = require('firebase-functions');
const nodemailer = require('nodemailer');

exports.sendVerificationEmail = functions.https.onCall(async (data, context) => {
  const { email, code } = data;
  
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD
    }
  });

  await transporter.sendMail({
    from: 'Attendy App <noreply@attendy.com>',
    to: email,
    subject: 'Your Verification Code',
    html: `Your code is: <strong>${code}</strong>`
  });

  return { success: true };
});
```

**Flutter side:**
```dart
final callable = FirebaseFunctions.instance.httpsCallable('sendVerificationEmail');
await callable.call({'email': email, 'code': code});
```

### 3. Use Third-Party Email Services

#### SendGrid (Free tier: 100 emails/day)
```yaml
dependencies:
  http: ^1.1.0
```

```dart
Future<void> sendEmailViaSendGrid(String email, String code) async {
  final response = await http.post(
    Uri.parse('https://api.sendgrid.com/v3/mail/send'),
    headers: {
      'Authorization': 'Bearer YOUR_SENDGRID_API_KEY',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'personalizations': [
        {'to': [{'email': email}]}
      ],
      'from': {'email': 'noreply@yourdomain.com'},
      'subject': 'Verification Code',
      'content': [
        {'type': 'text/html', 'value': 'Your code: $code'}
      ]
    }),
  );
}
```

#### Mailgun (Free tier: 5,000 emails/month)
#### AWS SES (Free tier: 62,000 emails/month)
#### Twilio SendGrid

---

## Troubleshooting

### Error: "Invalid login: 535-5.7.8"
- Your Gmail credentials are incorrect
- You haven't created an App Password
- 2-Step Verification is not enabled

### Error: "Connection timeout"
- Check internet connection
- Firewall might be blocking port 587/465
- Try different SMTP port (587 vs 465)

### Emails going to Spam
- Add SPF/DKIM records to your domain
- Use a custom domain instead of Gmail
- Warm up your email account gradually
- Ask recipients to whitelist your email

### Rate Limiting
- Gmail: ~500 emails/day
- For high volume, use dedicated email service

---

## Security Checklist

- [ ] Never commit email credentials to version control
- [ ] Use environment variables or secure storage
- [ ] Enable 2-Step Verification on email account
- [ ] Use App Passwords, not account passwords
- [ ] Consider using Firebase Cloud Functions
- [ ] Add `.env` to `.gitignore`
- [ ] Rotate credentials periodically
- [ ] Monitor email sending logs

---

## Testing Checklist

- [ ] Test student registration email
- [ ] Test teacher registration email
- [ ] Test forgot password email
- [ ] Test email verification resend
- [ ] Check email formatting on mobile
- [ ] Check email in spam folder
- [ ] Test with different email providers (Gmail, Outlook, Yahoo)
- [ ] Test with invalid email addresses

---

**Important:** After configuring email credentials, remember to:
1. Run `flutter pub get` to install mailer package
2. Update email credentials in `email_service.dart`
3. Test with a real email address
4. Never share your app password publicly!
