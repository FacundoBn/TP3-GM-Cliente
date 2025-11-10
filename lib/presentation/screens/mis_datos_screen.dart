import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/current_user_provider.dart';
import 'package:tp3_v2/presentation/widgets/app_scaffold.dart';

class MisDatosScreen extends ConsumerStatefulWidget {
  const MisDatosScreen({super.key});

  @override
  ConsumerState<MisDatosScreen> createState() => _MisDatosScreenState();
}

class _MisDatosScreenState extends ConsumerState<MisDatosScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;

  bool _savingName = false;
  bool _savingEmail = false;
  bool _editingName = false;
  bool _editingEmail = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName(String uid) async {
    setState(() => _savingName = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'uid': uid,
          'displayName': _nameCtrl.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (mounted) {
        setState(() => _editingName = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _saveEmail(String uid) async {
    setState(() => _savingEmail = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'uid': uid,
          'email': _emailCtrl.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (mounted) {
        setState(() => _editingEmail = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 acá estaba el nombre mal
    final userAsync = ref.watch(currentUserProvider);

    return AppScaffold(
      title: 'Mis datos',
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text('No hay sesión activa'));
          }

          final displayName = (userData['displayName'] ?? '') as String;
          final email = (userData['email'] ?? '') as String;
          final roles =
              (userData['roleIds'] as List?)?.cast<String>() ?? const <String>[];

          final uid = FirebaseAuth.instance.currentUser!.uid;

          // rellenamos controllers solo si están vacíos
          if (_nameCtrl.text.isEmpty) _nameCtrl.text = displayName;
          if (_emailCtrl.text.isEmpty) _emailCtrl.text = email;

          final ticketsQuery = FirebaseFirestore.instance
              .collection('tickets')
              .where('userId', isEqualTo: uid)
              .snapshots();

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ticketsQuery,
            builder: (context, snap) {
              final plates = <String>{};
              if (snap.hasData) {
                for (final doc in snap.data!.docs) {
                  final data = doc.data();
                  final plate =
                  (data['vehiclePlate'] ?? data['plate'] ?? '') as String;
                  if (plate.isNotEmpty) plates.add(plate);
                }
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Datos del usuario',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // ===== Nombre =====
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 110,
                        child: Text(
                          'Nombre:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: _editingName
                            ? TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        )
                            : Text(displayName.isEmpty ? '—' : displayName),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _editingName ? Icons.close : Icons.edit,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _editingName = !_editingName;
                            if (!_editingName) {
                              _nameCtrl.text = displayName;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (_editingName)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _savingName ? null : () => _saveName(uid),
                        icon: _savingName
                            ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.save),
                        label: Text(_savingName ? 'Guardando...' : 'Guardar'),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ===== Email =====
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 110,
                        child: Text(
                          'Email:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: _editingEmail
                            ? TextField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        )
                            : Text(email.isEmpty ? '—' : email),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _editingEmail ? Icons.close : Icons.edit,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _editingEmail = !_editingEmail;
                            if (!_editingEmail) {
                              _emailCtrl.text = email;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (_editingEmail)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _savingEmail ? null : () => _saveEmail(uid),
                        icon: _savingEmail
                            ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.save),
                        label: Text(_savingEmail ? 'Guardando...' : 'Guardar'),
                      ),
                    ),

                  const SizedBox(height: 12),
                  if (roles.isNotEmpty)
                    _InfoRow(label: 'Roles', value: roles.join(', ')),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  const Text(
                    'Patentes registradas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (snap.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (plates.isEmpty)
                    const Text('Todavía no hay patentes registradas.')
                  else
                    ...plates.map(
                          (p) => ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: Text(p),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
