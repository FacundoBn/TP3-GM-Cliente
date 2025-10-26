import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tp3_v2/presentation/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';

class TicketScreen extends StatelessWidget {
  final String ticketId;
  const TicketScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    final doc = FirebaseFirestore.instance.collection('tickets').doc(ticketId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: doc.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const AppScaffold(
            title: 'Comprobante',
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const AppScaffold(
            title: 'Comprobante',
            body: Center(child: Text('Ticket no encontrado')),
          );
        }

        final data = snap.data!.data()!;
        // Solo los campos que mostramos en el comprobante, con fallbacks
        final plate = (data['vehiclePlate'] ?? data['plate'] ?? '') as String;
        final ingresoTs = data['ingreso'] as Timestamp?;
        final egresoTs  = data['egreso']  as Timestamp?;
        final ingreso   = ingresoTs?.toDate();
        final egreso    = egresoTs?.toDate();
        final precio    = (data['precioFinal'] ?? 0).toDouble();

        return AppScaffold(
          title: 'Comprobante',
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumen de estadía',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Text('Patente: ${plate.isEmpty ? "(sin dato)" : plate}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('Inicio:  ${ingreso?.toLocal() ?? "-"}'),
                    Text('Fin:     ${egreso?.toLocal() ?? "-"}'),
                    const Divider(height: 24),
                    Text('Total:   \$${precio.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.home),
                        label: const Text('Volver al inicio'),
                        onPressed: () => context.go('/home'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
