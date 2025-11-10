import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/auth_provider.dart';
import 'package:tp3_v2/data/user_service.dart';

/// Devuelvo el doc de Firestore del usuario actual como Map<String, dynamic>?
/// Si no hay sesión, devuelvo null.
final currentUserProvider =
StreamProvider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (firebaseUser) {
      if (firebaseUser == null) {
        return Stream<Map<String, dynamic>?>.value(null);
      }

      final userService = ref.read(userServiceProvider);
      return userService.streamUser(firebaseUser.uid);
    },
  );
});
