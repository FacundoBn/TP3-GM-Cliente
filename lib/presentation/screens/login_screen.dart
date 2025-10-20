import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isRegister = false;
  
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isRegister ? 'Registrar' : 'Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              try{
              if (isRegister) {
                await auth.register(emailCtrl.text, passCtrl.text);
              } else {
                await auth.signIn(emailCtrl.text, passCtrl.text);
              }
              } catch (e){
                String msg = e.toString();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              }
            },
            child: Text(isRegister ? 'Registrar' : 'Entrar'),
          ),
          TextButton(
            onPressed: () => setState(() => isRegister = !isRegister),
            child: Text(isRegister ? 'Ya tengo cuenta' : 'Crear cuenta nueva'),
          )
        ]),
      ),
    );
  }
}
