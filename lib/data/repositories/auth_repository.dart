import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamebooking/data/models/user_model.dart';
import 'package:gamebooking/data/services/firebase_auth_service.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get firebaseUser => _authService.currentUser;

  // Sign in with email & password
  Future<UserModel> loginWithEmail(String email, String password) async {
    final credential = await _authService.signInWithEmail(email, password);
    return _getUserModel(credential.user!);
  }

  // Register with email & password
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'player',
  }) async {
    final credential = await _authService.registerWithEmail(email, password);
    final user = credential.user!;

    await _authService.updateDisplayName(name);

    final userRole = UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.player,
    );

    final userModel = UserModel(
      id: user.uid,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: user.photoURL,
      role: userRole,
      membershipType: MembershipType.free,
      totalBookings: 0,
      favoriteVenues: [],
      createdAt: DateTime.now(),
    );

    // Write profile to Firestore with timeout to prevent hanging
    // if Firestore rules block the write or network is slow
    try {
      await _firestoreService
          .createUserProfile(user.uid, userModel.toJson())
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Profile write failed or timed out — user is still registered in Auth
      // Profile will be created on next login via _getOrCreateProfile
    }

    return userModel;
  }

  // Sign in with Google
  Future<UserModel> loginWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    final user = credential.user!;
    return _getOrCreateProfile(user);
  }

  // Sign in with Apple
  Future<UserModel> loginWithApple() async {
    final credential = await _authService.signInWithApple();
    final user = credential.user!;
    return _getOrCreateProfile(user);
  }

  // Sign out
  Future<void> logout() async {
    await _authService.signOut();
  }

  // Get current user model
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return null;
    return _getUserModel(firebaseUser);
  }

  // Update user profile
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    await _firestoreService.updateUserProfile(
      updatedUser.id,
      updatedUser.toJson(),
    );
    if (updatedUser.name.isNotEmpty) {
      await _authService.updateDisplayName(updatedUser.name);
    }
    return updatedUser;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  /// Permanently deletes the current user's account.
  ///
  /// Deletes the Firestore user document first (best-effort) and then
  /// removes the Firebase Auth user. If Auth throws
  /// `requires-recent-login`, the UI should prompt the user to sign in
  /// again and retry.
  Future<void> deleteAccount() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      throw Exception('No user is currently signed in.');
    }

    final uid = firebaseUser.uid;

    // Best-effort: wipe the Firestore profile. Don't block the Auth
    // delete on a Firestore failure — leaving a dangling doc is less bad
    // than leaving a dangling Auth user the owner can't remove.
    try {
      await _firestoreService
          .deleteUserProfile(uid)
          .timeout(const Duration(seconds: 5));
    } catch (_) {}

    // This throws FirebaseAuthException('requires-recent-login') if the
    // user's credential is stale — caller must surface that to the UI.
    await _authService.deleteAccount();
  }

  // Get existing profile or create a new one for social sign-in users.
  // Falls back to Firebase Auth data if Firestore is unavailable.
  Future<UserModel> _getOrCreateProfile(User user) async {
    final fallbackModel = UserModel(
      id: user.uid,
      name: user.displayName ?? 'Player',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      avatarUrl: user.photoURL,
      role: UserRole.player,
      membershipType: MembershipType.free,
      totalBookings: 0,
      favoriteVenues: [],
      createdAt: DateTime.now(),
    );

    try {
      final existingProfile = await _firestoreService
          .getUserProfile(user.uid)
          .timeout(const Duration(seconds: 5));
      if (existingProfile != null) {
        return UserModel.fromJson(existingProfile);
      }
      await _firestoreService
          .createUserProfile(user.uid, fallbackModel.toJson())
          .timeout(const Duration(seconds: 5));
      return fallbackModel;
    } catch (_) {
      // Firestore unavailable — return model from Firebase Auth data
      return fallbackModel;
    }
  }

  // Helper to convert Firebase User to UserModel
  Future<UserModel> _getUserModel(User user) async {
    try {
      final profile = await _firestoreService
          .getUserProfile(user.uid)
          .timeout(const Duration(seconds: 5));
      if (profile != null) {
        return UserModel.fromJson(profile);
      }
    } catch (_) {
      // Firestore unavailable or timed out — fall through to fallback
    }

    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'Player',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      avatarUrl: user.photoURL,
      role: UserRole.player,
      membershipType: MembershipType.free,
      totalBookings: 0,
      favoriteVenues: [],
      createdAt: DateTime.now(),
    );
  }
}
