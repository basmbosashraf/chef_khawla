import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// تسجيل حساب جديد
  static Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print("Signup error: $e");
      return false;
    }
  }

  /// تسجيل الدخول
  static Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

 static bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}
