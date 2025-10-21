import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tp3_v2/domain/logic/current_user_provider.dart';
import 'package:tp3_v2/presentation/screens/login_screen.dart';
import 'package:tp3_v2/presentation/screens/register_screen.dart';
import 'package:tp3_v2/presentation/screens/home_screen.dart';
import 'package:tp3_v2/presentation/screens/history_screen.dart';
import 'package:tp3_v2/presentation/screens/active_session_screen.dart';
import 'package:tp3_v2/presentation/screens/mis_datos_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider).value;

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      final registering = state.matchedLocation == '/register';

      if (user != null && (loggingIn || registering)) return '/home';
      if (user == null && !loggingIn && !registering) return '/login';
      return null;
    },
    routes: [
      // públicas
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => RegisterScreen()),

      // privadas
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/perfil', builder: (_, __) => const MisDatosScreen()),
      GoRoute(
        path: '/active',
        builder: (_, state) {
          final ticketId = state.extra is String ? state.extra as String : null;
          return ActiveSessionScreen(ticketId: ticketId, readOnly: true);
        },
      ),
    ],
  );
});
