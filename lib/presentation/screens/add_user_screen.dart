

// ---- Pantalla de Usuarios ----
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/user_provider.dart';
import 'package:tp3_v2/domain/models/user_model.dart';


// pantalla de prueba, no operativa en nuevas versiones.
class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen({super.key});

  @override
  ConsumerState<AddUserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _cuitController = TextEditingController();
  final _userNameController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _cuitController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _addUser() async {
    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        cuit: _cuitController.text.trim().isEmpty ? null : _cuitController.text.trim(),
        userName: _userNameController.text.trim(), uid: '', email: '', createdAt: DateTime.now(),
        
      );

      await ref.read(usersProvider.notifier).addUser(newUser);

      // Limpia campos
      _nombreController.clear();
      _apellidoController.clear();
      _cuitController.clear();
      _userNameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios Firestore')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: _cuitController,
                    decoration: const InputDecoration(labelText: 'CUIT (opcional)'),
                  ),
                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(labelText: 'UserName'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addUser,
                    child: const Text('Agregar Usuario'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Usuarios cargados:'),
            Expanded(
              child: ListView(
                children: users.values.map((u) {
                  return ListTile(
                    title: Text('${u.nombre} ${u.apellido}'),
                    subtitle: Text(u.userName),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}