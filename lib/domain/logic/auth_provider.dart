import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:tp3_v2/data/auth_service.dart';
import 'package:tp3_v2/domain/logic/current_user_provider.dart';


final authServiceProvider = Provider<AuthService>((ref) {
  final userService = ref.read (userServiceProvider);
  return AuthService(userService);
});

final authStateProvider = StreamProvider<fb.User?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges();
});
