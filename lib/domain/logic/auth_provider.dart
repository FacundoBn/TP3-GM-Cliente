import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tp3_v2/data/auth_service.dart';
import 'package:tp3_v2/data/user_service.dart';

/// Proveedor de UserService
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Proveedor de AuthService (inyectando UserService)
final authServiceProvider = Provider<AuthService>((ref) {
  final userService = ref.read(userServiceProvider);
  return AuthService(userService: userService);
});

/// Stream del estado de autenticación
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final service = ref.read(authServiceProvider);
  return service.authStateChanges();
});

/// Alias para compatibilidad con código existente
final authStateProvider = authStateChangesProvider;
