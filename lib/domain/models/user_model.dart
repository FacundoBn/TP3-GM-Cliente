import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/current_user_provider.dart';
import 'package:tp3_v2/presentation/widgets/app_scaffold.dart';

class MisDatosScreen extends ConsumerWidget {
  const MisDatosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return AppScaffold(
      title: 'Mis datos',
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (userModel) {
          if (userModel == null) {
            return const Center(child: Text('No hay sesión activa'));
          }

          final uid = userModel.uid;

          final ticketsStream = FirebaseFirestore.instance
              .collection('tickets')
              .where('userId', isEqualTo: uid)
              .snapshots();

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ticketsStream,
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Nombre',
                    value: userModel.displayName ?? '—',
                  ),
                  _InfoRow(
                    label: 'Email',
                    value: userModel.email ?? '—',
                  ),
                  if (userModel.roleIds != null &&
                      userModel.roleIds!.isNotEmpty)
                    _InfoRow(
                      label: 'Roles',
                      value: userModel.roleIds!.join(', '),
                    ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  const Text(
                    'Patentes registradas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
