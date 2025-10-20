import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tp3_v2/domain/logic/auth_provider.dart';
import 'package:tp3_v2/domain/logic/current_user_provider.dart';

class AppScaffold extends ConsumerWidget { // ✅ Cambiar a ConsumerWidget
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { // ✅ Recibe WidgetRef
    final canPop = Navigator.of(context).canPop();
    final currentUser = ref.watch(currentUserProvider).value; // ✅ Accede al provider
    final email = currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                tooltip: 'Volver',
              )
            : Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  tooltip: 'Menú',
                ),
              ),
        actions: actions,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (email.isNotEmpty)
                UserAccountsDrawerHeader(
                  accountName: Text(currentUser?.nombre ?? 'Usuario'), // ✅ Nombre del usuario
                  accountEmail: Text(email),
                  currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
                ),
              _tile(context, Icons.home,      'Home',            '/home'),
              _tile(context, Icons.qr_code,   'Escanear',        '/scan'),
              _tile(context, Icons.history,   'Historial',       '/history'),
              _tile(context, Icons.settings,  'Ajustes',         '/settings'),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Salir'),
                onTap: () => _logout(context, ref), // ✅ Pasar ref al método
              ),
            ],
          ),
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  // ✅ Método para logout usando Riverpod
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context); // cerrar drawer
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    // La reactividad de AuthGate manejará la navegación automáticamente
  }

  ListTile _tile(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context); // cerrar drawer
        context.go(route);
      },
    );
  }
}