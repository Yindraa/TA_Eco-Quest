import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login/login_screen.dart';
import '../screens/login/reset_password_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/shared/role_aware_shell.dart';

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final loc = state.matchedLocation;

    if (loc == '/splash') return null;
    if (loc == '/reset-password') return null;

    if (!isLoggedIn && loc != '/login') return '/login';
    if (isLoggedIn && loc == '/login') return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ResetPasswordScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RoleAwareShell(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (context, animation, _, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOut);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    ),
  ],
);
