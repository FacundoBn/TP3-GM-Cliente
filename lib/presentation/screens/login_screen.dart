import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/auth_provider.dart';
import 'package:tp3_v2/presentation/widgets/app_text_field.dart';
import 'package:tp3_v2/presentation/widgets/primary_button.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final emailCtrl = TextEditingController();
//   final passCtrl = TextEditingController();
//   bool isRegister = false;
  
//   @override
//   Widget build(BuildContext context) {
//     final auth = ref.watch(authServiceProvider);

//     return Scaffold(
//       appBar: AppBar(title: Text(isRegister ? 'Registrar' : 'Iniciar sesión')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(children: [
//           TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
//           TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () async {
//               try{
//               if (isRegister) {
//                 await auth.register(emailCtrl.text, passCtrl.text);
//               } else {
//                 await auth.signIn(emailCtrl.text, passCtrl.text);
//               }
//               } catch (e){
//                 String msg = e.toString();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(msg)),
//                 );
//               }
//             },
//             child: Text(isRegister ? 'Registrar' : 'Entrar'),
//           ),
//           TextButton(
//             onPressed: () => setState(() => isRegister = !isRegister),
//             child: Text(isRegister ? 'Ya tengo cuenta' : 'Crear cuenta nueva'),
//           )
//         ]),
//       ),
//     );
//   }
// }
class LoginScreen extends ConsumerStatefulWidget { 
  final VoidCallback onToggleAuthMode;
  
  const LoginScreen({super.key, required this.onToggleAuthMode}); 
  
  @override 
  ConsumerState<LoginScreen> createState() => _LoginScreenState(); 
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController(text: 'admin@demo.com');
  final passCtrl = TextEditingController(text: '123456');
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
      final authService = ref.read(authServiceProvider);
      await authService.signIn(emailCtrl.text, passCtrl.text);
      // ✅ La reactividad de AuthGate redirigirá automáticamente a HomeScreen
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                onPressed: widget.onToggleAuthMode, 
                child: const Text('Crear cuenta nueva')
              ),
            ]),
          ),
        ),
      ),
    );
  }
}