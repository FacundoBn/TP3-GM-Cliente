import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/data/user_service.dart';
import 'package:tp3_v2/domain/logic/auth_provider.dart';
import 'package:tp3_v2/domain/models/user_model.dart';

final userServiceProvider = Provider<UserService>((ref){
  return UserService();
});
 
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  print('AuthState: $authState');
  // Si el auth aún está cargando, devolvemos un stream "en espera"
  if (authState.isLoading) return const Stream.empty();

  final authUser = authState.value;
  
  if (authUser == null) return Stream.value(null);

  // Si hay usuario, escuchamos su documento en Firestore
  final userService = ref.watch(userServiceProvider);
  return userService.currentUser(authUser.uid);
});

