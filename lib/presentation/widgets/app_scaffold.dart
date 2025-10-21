import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Scaffold común con:
/// - AppBar que muestra Back si puede, sino hamburguesa
/// - Drawer de navegación
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showMenu; // en Login/Register: false

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.actions,
    this.floatingActionButton,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : (showMenu
                ? Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  )
                : null),
        actions: actions,
        bottom: bottom,
      ),
      drawer: showMenu ? _AppDrawer() : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Future<void> go(String route) async {
      Navigator.of(context).pop(); // cerrar drawer
      context.go(route);
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? ''),
              accountEmail: Text(user?.email ?? 'Invitado'),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => go('/home'),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Escanear'),
              onTap: () => go('/scan'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial'),
              onTap: () => go('/history'),
            ),
            const Spacer(),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // limpiar stack y enviar a login
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
