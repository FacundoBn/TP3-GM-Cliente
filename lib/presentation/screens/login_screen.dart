import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tp3_v2/domain/logic/auth_provider.dart';
import 'package:tp3_v2/presentation/widgets/app_text_field.dart';
import 'package:tp3_v2/presentation/widgets/primary_button.dart';
import 'package:tp3_v2/data/user_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController(text: 'admin@demo.com');
  final passCtrl  = TextEditingController(text: '123456');
  bool _isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // 1) Login con tu servicio actual (Riverpod)
      final authService = ref.read(authServiceProvider);
      await authService.signIn(emailCtrl.text.trim(), passCtrl.text);

      // 2) Garantizar users/{uid} con roleIds:["cliente"] en el primer ingreso
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserService().ensureClientUserDoc(user);
      }

      // ✅ AuthGate / listener redirige a Home automáticamente
      // Si no tuvieras AuthGate, podrías hacer: context.go('/');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: emailCtrl, label: 'Email'),
                const SizedBox(height: 12),
                AppTextField(controller: passCtrl, label: 'Clave', obscure: true),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Ingresar',
                  loading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Crear cuenta nueva'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
