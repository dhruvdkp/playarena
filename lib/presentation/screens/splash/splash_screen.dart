import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/constants/app_strings.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/data/models/user_model.dart';

/// Animated splash screen that checks onboarding + auth state before navigating.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _glowController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _glowOpacity;

  // Navigate only once the minimum splash time has elapsed AND the
  // AuthBloc has resolved to either `AuthAuthenticated` or
  // `AuthUnauthenticated`. Otherwise we would route based on the
  // transient `AuthInitial` / `AuthLoading` state and briefly flash the
  // login screen before `AuthCheckStatus` completes.
  bool _minTimeElapsed = false;
  bool _authResolved = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // ── Logo animation ───────────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // ── Text animation ───────────────────────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // ── Glow pulse animation ─────────────────────────────────────────
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowOpacity = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // ── Start animation sequence ─────────────────────────────────────
    _logoController.forward();

    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textController.forward();
        _glowController.repeat(reverse: true);
      }
    });

    // ── Kick off the minimum-display timer ───────────────────────────
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _minTimeElapsed = true;
      _maybeNavigate();
    });

    // ── Check auth synchronously in case it's already resolved ───────
    // (e.g. the user hot-restarted and Firebase had a cached session).
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated || authState is AuthUnauthenticated) {
      _authResolved = true;
    }
  }

  /// Performs the actual navigation once both:
  ///   - the minimum splash time has elapsed, AND
  ///   - the AuthBloc has resolved (we're no longer in AuthInitial/Loading).
  ///
  /// Without the auth-resolved gate, a cold start would route to `/login`
  /// for a second before `AuthCheckStatus` completes and bounces the
  /// authenticated user back to `/home`.
  Future<void> _maybeNavigate() async {
    if (_navigated || !_minTimeElapsed || !_authResolved) return;
    _navigated = true;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
    if (!mounted) return;

    if (!onboardingDone) {
      context.go(AppRoutes.onboarding);
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.role == UserRole.admin) {
        context.go(AppRoutes.adminDashboard);
      } else {
        context.go(AppRoutes.home);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthUnauthenticated) {
          _authResolved = true;
          _maybeNavigate();
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            // Theme-aware gradient — dark stadium-night in dark mode,
            // soft gray-to-white in light mode. Uses `primaryBackground`
            // and `surface` from the active palette.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryBackground,
                AppColors.surface,
                AppColors.primaryBackground,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Glowing Logo ───────────────────────────────────────
              AnimatedBuilder(
                animation: Listenable.merge([_logoController, _glowController]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _buildGlowingLogo(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // ── App Name ───────────────────────────────────────────
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Tagline ────────────────────────────────────────────
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    AppStrings.tagline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.actionGreen,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 64),

              // ── Loading indicator ──────────────────────────────────
              FadeTransition(
                opacity: _textOpacity,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.actionGreen.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildGlowingLogo() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.actionGreen.withValues(
                  alpha: _glowOpacity.value * 0.4,
                ),
                blurRadius: 40,
                spreadRadius: 15,
              ),
              BoxShadow(
                color: AppColors.actionGreen.withValues(
                  alpha: _glowOpacity.value * 0.2,
                ),
                blurRadius: 80,
                spreadRadius: 30,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.actionGreen.withValues(alpha: 0.15),
                  AppColors.actionGreen.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.sports_cricket,
                size: 56,
                color: AppColors.actionGreen,
              ),
            ),
          ),
        );
      },
    );
  }
}
