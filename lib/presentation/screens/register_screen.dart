import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tp3_v2/domain/logic/auth_provider.dart';
import 'package:tp3_v2/presentation/widgets/app_text_field.dart';
import 'package:tp3_v2/presentation/widgets/primary_button.dart';
import 'package:tp3_v2/data/user_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();
  final pass2Ctrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading) return;

    // Validaciones básicas
    if (passCtrl.text != pass2Ctrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las claves no coinciden')),
      );
      return;
    }
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completar email y clave')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1) Registrar con tu servicio (Riverpod)
      final authService = ref.read(authServiceProvider);
      await authService.register(emailCtrl.text.trim(), passCtrl.text);

      // 2) Garantizar users/{uid} con roleIds:["cliente"]
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserService().ensureClientUserDoc(user);
      }

      // ✅ Si usás AuthGate, te redirige solo al Home.
      // Si querés forzar navegación:
      // if (mounted) context.go('/');

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
      appBar: AppBar(title: const Text('Crear cuenta')),
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
                AppTextField(controller: passCtrl,  label: 'Clave',        obscure: true),
                const SizedBox(height: 12),
                AppTextField(controller: pass2Ctrl, label: 'Repetir clave', obscure: true),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Registrarme',
                  loading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Ya tengo cuenta. Ingresar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
