import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/data/models/user_model.dart';
import 'package:gamebooking/data/repositories/auth_repository.dart';
import 'package:gamebooking/data/services/analytics_service.dart';
import 'package:gamebooking/data/services/crashlytics_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  AuthBloc({
    required AuthRepository authRepository,
    required AnalyticsService analyticsService,
    required CrashlyticsService crashlyticsService,
  })  : _authRepository = authRepository,
        _analyticsService = analyticsService,
        _crashlyticsService = crashlyticsService,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthAppleSignInRequested>(_onAppleSignIn);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthResetPasswordRequested>(_onResetPassword);
    on<AuthDeleteAccountRequested>(_onDeleteAccount);
  }

  Future<void> _onDeleteAccount(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.deleteAccount();
      emit(const AuthUnauthenticated());
    } catch (e, stack) {
      await _crashlyticsService.recordError(e, stack);
      emit(AuthError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.loginWithEmail(
        event.email,
        event.password,
      );
      await _analyticsService.logLogin('email');
      await _analyticsService.setUserId(user.id);
      _crashlyticsService.setUserIdentifier(user.id);
      emit(AuthAuthenticated(user: user));
    } catch (e, stack) {
      await _crashlyticsService.recordError(e, stack);
      emit(AuthError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.loginWithGoogle();
      await _analyticsService.logLogin('google');
      await _analyticsService.setUserId(user.id);
      _crashlyticsService.setUserIdentifier(user.id);
      emit(AuthAuthenticated(user: user));
    } catch (e, stack) {
      await _crashlyticsService.recordError(e, stack);
      emit(AuthError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onAppleSignIn(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.loginWithApple();
      await _analyticsService.logLogin('apple');
      await _analyticsService.setUserId(user.id);
      _crashlyticsService.setUserIdentifier(user.id);
      emit(AuthAuthenticated(user: user));
    } catch (e, stack) {
      await _crashlyticsService.recordError(e, stack);
      emit(AuthError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.registerWithEmail(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
        role: event.role,
      );
      await _analyticsService.logSignUp('email');
      await _analyticsService.setUserId(user.id);
      _crashlyticsService.setUserIdentifier(user.id);
      emit(AuthAuthenticated(user: user));
    } catch (e, stack) {
      await _crashlyticsService.recordError(e, stack);
      emit(AuthError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e, stack) {
      await _crashlyticsService.recordError(e, stack);
      emit(AuthError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        await _analyticsService.setUserId(user.id);
        _crashlyticsService.setUserIdentifier(user.id);
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final updatedUser = await _authRepository.updateProfile(event.user);
      emit(AuthAuthenticated(user: updatedUser));
    } catch (e, stack) {
      await _crashlyticsService.recordError(e, stack);
      emit(AuthError(message: _parseErrorMessage(e)));
    }
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.resetPassword(event.email);
      emit(const AuthPasswordResetSent());
    } catch (e, stack) {
      await _crashlyticsService.recordError(e, stack);
      emit(AuthError(message: _parseErrorMessage(e)));
    }
  }

  String _parseErrorMessage(dynamic error) {
    final msg = error.toString();
    if (msg.contains('user-not-found')) return 'No account found with this email';
    if (msg.contains('wrong-password')) return 'Incorrect password';
    if (msg.contains('email-already-in-use')) return 'Email is already registered';
    if (msg.contains('weak-password')) return 'Password is too weak';
    if (msg.contains('invalid-email')) return 'Invalid email address';
    if (msg.contains('network-request-failed')) return 'Network error. Check your connection';
    if (msg.contains('too-many-requests')) return 'Too many attempts. Try again later';
    if (msg.contains('sign_in_canceled') || msg.contains('canceled')) return 'Sign in cancelled';
    if (msg.contains('Exception: ')) return msg.replaceFirst('Exception: ', '');
    return 'Something went wrong. Please try again';
  }
}
