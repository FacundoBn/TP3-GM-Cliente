import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/current_user_provider.dart';
import 'package:tp3_v2/presentation/screens/history_screen.dart';
import 'package:tp3_v2/presentation/screens/login_screen.dart';
import 'package:tp3_v2/presentation/screens/register_screen.dart';
import 'package:tp3_v2/presentation/screens/home_screen.dart';
import 'package:tp3_v2/presentation/screens/scan_screen.dart';

final _key = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // Escucha cambios de autenticación
  final user = ref.watch(currentUserProvider).value;

  return GoRouter(
    navigatorKey: _key,
    initialLocation: '/home',

    /* ==========  AUTH-GATE CON REDIRECT  ========== */
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      final registering = state.matchedLocation == '/register';

      // Si va a login/register y YA está logueado → sacarlo de ahí
      if (user != null && (loggingIn || registering)) return '/home';

      // Si va a cualquier otra cosa y NO está logueado → forzar login
      if (user == null && !loggingIn && !registering) return '/login';

      // En cualquier otro caso dejar pasar
      return null;
    },

    routes: [
      /* --- públicas --- */
      GoRoute(path: '/login',   builder: (_, __) =>  LoginScreen()),
      GoRoute(path: '/register',builder: (_, __) =>  RegisterScreen()),

      /* --- privadas (protegidas por redirect) --- */
      GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/scan',    builder: (_, __) => const ScanScreen()),
      GoRoute(path: '/otro',    builder: (_, __) => const Placeholder()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/settings',builder: (_, __) => const Placeholder()),
    ],
  );
});