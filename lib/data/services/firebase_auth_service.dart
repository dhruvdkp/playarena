import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ---------------------------------------------------------------------------
  // Reactive streams & current user
  // ---------------------------------------------------------------------------

  /// Stream that emits whenever the authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in user, or `null` if not authenticated.
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Email & Password
  // ---------------------------------------------------------------------------

  /// Signs in an existing user with [email] and [password].
  ///
  /// Returns the [UserCredential] on success.
  /// Throws a [FirebaseAuthException] on failure.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: 'An unexpected error occurred during sign in: $e',
      );
    }
  }

  /// Creates a new user account with [email] and [password].
  ///
  /// Returns the [UserCredential] on success.
  /// Throws a [FirebaseAuthException] on failure.
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'registration-failed',
        message: 'An unexpected error occurred during registration: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign In
  // ---------------------------------------------------------------------------

  /// Authenticates the user via Google Sign-In.
  ///
  /// Opens the native Google sign-in flow, retrieves an ID token and access
  /// token, builds an [OAuthCredential], and signs in to Firebase.
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-cancelled',
          message: 'Google sign in was cancelled by the user.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'An unexpected error occurred during Google sign in: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Apple Sign In
  // ---------------------------------------------------------------------------

  /// Authenticates the user via Sign in with Apple.
  ///
  /// Generates a secure nonce, opens the Apple sign-in sheet, builds an
  /// [OAuthCredential] from the returned identity token, and signs in to
  /// Firebase.
  Future<UserCredential> signInWithApple() async {
    try {
      // Generate a cryptographically-secure random nonce.
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final OAuthCredential oauthCredential =
          OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await _auth.signInWithCredential(oauthCredential);

      // Apple only returns the display name on the first sign-in. Persist it
      // to the Firebase profile so it is available in subsequent sessions.
      if (appleCredential.givenName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(displayName);
        }
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'apple-sign-in-failed',
        message: 'An unexpected error occurred during Apple sign in: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Signs out the current user from Firebase and any third-party providers.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'sign-out-failed',
        message: 'An error occurred during sign out: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------

  /// Sends a password-reset email to the given [email] address.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'password-reset-failed',
        message: 'An error occurred while sending password reset email: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Profile Updates
  // ---------------------------------------------------------------------------

  /// Updates the current user's display name.
  Future<void> updateDisplayName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently signed in.',
        );
      }
      await user.updateDisplayName(name);
      await user.reload();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'update-display-name-failed',
        message: 'Failed to update display name: $e',
      );
    }
  }

  /// Updates the current user's profile photo URL.
  Future<void> updatePhotoURL(String url) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently signed in.',
        );
      }
      await user.updatePhotoURL(url);
      await user.reload();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'update-photo-url-failed',
        message: 'Failed to update photo URL: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Account Deletion
  // ---------------------------------------------------------------------------

  /// Permanently deletes the current user's account.
  ///
  /// The user may need to re-authenticate before calling this if their last
  /// sign-in was too long ago.
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently signed in.',
        );
      }
      await user.delete();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'delete-account-failed',
        message: 'Failed to delete account: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Generates a cryptographically-secure random nonce of [length] characters.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the SHA-256 hash of [input] as a hex string.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Custom exception for Firebase auth errors that don't originate from the
/// Firebase SDK itself.
class FirebaseAuthException implements Exception {
  final String code;
  final String message;

  FirebaseAuthException({required this.code, required this.message});

  @override
  String toString() => 'FirebaseAuthException(code: $code, message: $message)';
}
