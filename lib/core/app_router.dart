// lib/core/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tp3_v2/presentation/screens/login_screen.dart';
import 'package:tp3_v2/presentation/screens/register_screen.dart';
import 'package:tp3_v2/presentation/screens/home_screen.dart';
import 'package:tp3_v2/presentation/screens/history_screen.dart';
import 'package:tp3_v2/presentation/screens/mis_datos_screen.dart';
import 'package:tp3_v2/presentation/screens/ticket_screen.dart';
import 'package:tp3_v2/presentation/screens/active_session_screen.dart';

final _authStreamProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(_authStreamProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isAuthPage = loc == '/login' || loc == '/register';
      final user = FirebaseAuth.instance.currentUser;

      if (user == null && !isAuthPage) return '/login';
      if (user != null && isAuthPage) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/mis-datos', builder: (_, __) => const MisDatosScreen()),

      GoRoute(
        path: '/ticket/:id',
        builder: (context, state) =>
            TicketScreen(ticketId: state.pathParameters['id']!),
      ),

      // Compat: /active sin id (muestra placeholder)
      GoRoute(
        path: '/active',
        builder: (_, __) => const ActiveSessionScreen(),
      ),

      // Detalle: /active/:id (MOSTRAR la estadía activa)
      GoRoute(
        path: '/active/:id',
        builder: (context, state) =>
            ActiveSessionScreen(ticketId: state.pathParameters['id']!),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
