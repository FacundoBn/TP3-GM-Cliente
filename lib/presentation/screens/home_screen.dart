import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/auth_provider.dart';
import 'package:tp3_v2/domain/models/user_model.dart';
import 'package:tp3_v2/presentation/screens/user_vehicles_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.currentUser});

  // 🔹 Recibe el usuario autenticado de Firebase
  final UserModel currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Sesión iniciada correctamente'),
            const SizedBox(height: 16),
            Text('e - mail: ${currentUser.email}'),
            Text('UID: ${currentUser.uid}'),
            Text('Nombre: ${currentUser.nombre}'),
            Text('Apellido: ${currentUser.apellido}'),
            Text('CUIT: ${currentUser.cuit?? 'sin CUIT'}'),
            const SizedBox(height: 24),
            Expanded(
              child: UserVehiclesScreen(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await authService.signOut();
        },
        child: Icon(Icons.logout))
    );
  }
}
