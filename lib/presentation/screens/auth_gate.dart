import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/current_user_provider.dart';
import 'package:tp3_v2/domain/models/user_model.dart';
import 'package:tp3_v2/presentation/screens/login_screen.dart';
import 'package:tp3_v2/presentation/screens/register_screen.dart';
import 'home_screen.dart';

// class AuthGate extends ConsumerWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userState = ref.watch(currentUserProvider);

//     return userState.when(
//       data: (user) {
//         if (user != null) return HomeScreen(currentUser:user);
//         return const LoginScreen();
//       },
//       loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
//     );
//   }
// }
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _showRegister = false;

  void _toggleAuthMode() {
    setState(() {
      _showRegister = !_showRegister;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(currentUserProvider);

    return userState.when(
      data: (user) {
        if (user != null) {
          // ✅ HomeScreen ahora es el CONTAINER del router
          return HomeScreen(currentUser: user);
        } else {
          return _showRegister 
              ? RegisterScreen(onToggleAuthMode: _toggleAuthMode)
              : LoginScreen(onToggleAuthMode: _toggleAuthMode);
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}