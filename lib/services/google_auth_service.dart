import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling Google Sign-In authentication with persistent login
class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  // SharedPreferences keys for persistent storage
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhotoKey = 'user_photo_url';

  /// Initialize the service and check for existing login
  Future<void> initialize() async {
    // Check if user was previously logged in
    final isLoggedIn = await _getStoredLoginState();
    if (isLoggedIn && _auth.currentUser == null) {
      // Try to restore Google Sign-In silently
      try {
        final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
        if (account != null) {
          final GoogleSignInAuthentication googleAuth = await account.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await _auth.signInWithCredential(credential);
          print('✅ Silent sign-in successful: ${account.email}');
        } else {
          // Clear stored state if silent sign-in failed
          await _clearStoredLoginState();
        }
      } catch (e) {
        print('⚠️ Silent sign-in failed: $e');
        await _clearStoredLoginState();
      }
    }
  }

  /// Sign in with Google
  /// Returns the User if successful, null if cancelled
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        print('❌ Google Sign-In cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Store login state and user info persistently
      await _storeLoginState(userCredential.user);

      print('✅ Google Sign-In successful: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    
    // Clear stored login state
    await _clearStoredLoginState();
    
    print('✅ Signed out from Google');
  }

  /// Check if user is already signed in with Google (from memory or storage)
  Future<bool> isSignedIn() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return true;
    }
    
    // Check stored login state
    return await _getStoredLoginState();
  }

  /// Get current Google user info
  GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;

  /// Get current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Store login state and user information
  Future<void> _storeLoginState(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userEmailKey, user.email ?? '');
      await prefs.setString(_userNameKey, user.displayName ?? '');
      await prefs.setString(_userPhotoKey, user.photoURL ?? '');
    } else {
      await _clearStoredLoginState();
    }
  }

  /// Get stored login state
  Future<bool> _getStoredLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Clear stored login state
  Future<void> _clearStoredLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhotoKey);
  }

  /// Get stored user information
  Future<Map<String, String?>> getStoredUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_userEmailKey),
      'name': prefs.getString(_userNameKey),
      'photoUrl': prefs.getString(_userPhotoKey),
    };
  }
}
