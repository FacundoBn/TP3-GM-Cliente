import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tp3_v2/domain/models/user_model.dart';
import 'package:tp3_v2/domain/logic/auth_provider.dart';
import 'package:tp3_v2/data/user_service.dart';

/// Devuelve el usuario de dominio (UserModel) como Stream, o null si no hay sesión.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider); // alias compat
  return authState.when(
    loading: () => Stream<UserModel?>.empty(),
    error: (_, __) => Stream<UserModel?>.empty(),
    data: (firebaseUser) {
      if (firebaseUser == null) return Stream<UserModel?>.value(null);

      final userService = ref.read(userServiceProvider);
      // Escuchamos el doc users/{uid} como Stream y mapeamos a UserModel
      return userService.streamUser(firebaseUser.uid).map((data) {
        if (data == null) return null;
        return UserModel.fromMap(firebaseUser.uid, data);
      });
    },
  );
});
