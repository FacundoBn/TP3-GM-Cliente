import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tp3_v2/domain/logic/current_user_provider.dart';
import 'package:tp3_v2/domain/models/user_model.dart';
import 'package:tp3_v2/presentation/widgets/app_scaffold.dart';

class HomeScreen extends ConsumerWidget {
 
  
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? currentUser = ref.watch(currentUserProvider).value;   
    return AppScaffold(
      
      title: 'Inicio',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${currentUser?.nombre}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Escanear patente'),
                subtitle: const Text('Registrar nuevo ingreso'),
                onTap: () => context.go('/scan'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historial'),
                subtitle: const Text('Ver tickets anteriores'),
                onTap: () => context.go('/history'),
              ),
            ),
            // ... más contenido de Home
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/scan'),
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}