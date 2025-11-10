import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tp3_v2/presentation/widgets/app_scaffold.dart';

class ActiveSessionScreen extends StatelessWidget {
  final String? ticketId;
  final bool readOnly;
  const ActiveSessionScreen({super.key, this.ticketId, this.readOnly = true});

  double _computePrice({
    required DateTime ingreso,
    required DateTime egreso,
    double blockMinutes = 15,
    double pricePerBlock = 250,
  }) {
    final minutes = egreso.difference(ingreso).inMinutes.clamp(0, 1 << 31);
    final blocks = (minutes / blockMinutes).ceil();
    return blocks * pricePerBlock;
  }

  Future<void> _finishAndGoToReceipt(
      BuildContext context,
      DocumentReference<Map<String, dynamic>> doc,
      Map<String, dynamic> data,
      ) async {
    final ingreso = (data['ingreso'] as Timestamp).toDate();
    final now = DateTime.now();
    final precio = _computePrice(ingreso: ingreso, egreso: now);

    await doc.update({
      'egreso': Timestamp.fromDate(now),
      'precioFinal': precio,
      'status': 'closed',
    });

    context.go('/ticket/${doc.id}');
  }

  @override
  Widget build(BuildContext context) {
    if (ticketId == null) {
      return const AppScaffold(
        title: 'Estadía activa',
        body: Center(child: Text('No hay estadía activa seleccionada.')),
      );
    }

    final doc = FirebaseFirestore.instance.collection('tickets').doc(ticketId);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: doc.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const AppScaffold(
            title: 'Estadía activa',
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const AppScaffold(
            title: 'Estadía activa',
            body: Center(child: Text('Ticket no encontrado.')),
          );
        }

        final d = snap.data!.data()!;
        final owner = d['userId'] as String?;
        if (uid == null || owner != uid) {
          return const AppScaffold(
            title: 'Estadía activa',
            body: Center(child: Text('No autorizado')),
          );
        }

        final plate   = (d['vehiclePlate'] ?? d['plate'] ?? '') as String;
        final ingreso = (d['ingreso'] as Timestamp).toDate();
        final egreso  = d['egreso'] != null ? (d['egreso'] as Timestamp).toDate() : null;
        final precio  = (d['precioFinal'] ?? 0).toDouble();

        final isActive = egreso == null;
        final endForDuration = isActive ? DateTime.now().toUtc() : egreso!.toUtc();
        final dur = endForDuration.difference(ingreso.toUtc());
        final hh = dur.inHours.toString().padLeft(2, '0');
        final mm = (dur.inMinutes % 60).toString().padLeft(2, '0');
        final ss = (dur.inSeconds % 60).toString().padLeft(2, '0');

        return AppScaffold(
          title: 'Estadía activa',
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.local_parking)),
                    title: Text('Patente: $plate'),
                    subtitle: Text('Inicio: ${ingreso.toLocal()}'),
                    trailing: Chip(
                      label: Text(isActive ? 'ACTIVO' : 'CERRADO'),
                      backgroundColor: isActive ? Colors.green.shade100 : Colors.blueGrey.shade100,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: isActive
                        ? Column(
                      children: [
                        const Text('Tiempo transcurrido'),
                        const SizedBox(height: 6),
                        Text('$hh:$mm:$ss',
                            style: Theme.of(context).textTheme.displaySmall),
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resumen', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('Inicio:  ${ingreso.toLocal()}'),
                        if (egreso != null) Text('Fin:     ${egreso.toLocal()}'),
                        const SizedBox(height: 8),
                        Text('Total:   \$${precio.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
