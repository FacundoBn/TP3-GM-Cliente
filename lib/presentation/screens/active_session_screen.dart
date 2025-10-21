import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Usa el scaffold común con hamburguesa/back
import 'package:tp3_v2/presentation/widgets/app_scaffold.dart';

class ActiveSessionScreen extends StatelessWidget {
  final String? ticketId;
  const ActiveSessionScreen({super.key, this.ticketId});

  @override
  Widget build(BuildContext context) {
    if (ticketId == null) {
      return const AppScaffold(
        title: 'Estadía activa',
        body: Center(child: Text('No hay estadía activa seleccionada.')),
      );
    }

    final doc = FirebaseFirestore.instance.collection('tickets').doc(ticketId);

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
        final plate  = (d['plate'] ?? '') as String;
        final status = (d['status'] ?? '') as String; // 'active' | 'closed'
        final ingreso = (d['ingreso'] as Timestamp).toDate();
        final egreso  = d['egreso'] != null ? (d['egreso'] as Timestamp).toDate() : null;
        final precio  = d['precioFinal'];

        final isActive = status == 'active';

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

                // Timer en vivo si está activo; si está cerrado, muestra rango y total
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: isActive
                        ? _LiveTimer(from: ingreso)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Resumen', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('Inicio:  ${ingreso.toLocal()}'),
                              if (egreso != null) Text('Fin:     ${egreso.toLocal()}'),
                              const SizedBox(height: 8),
                              Text('Total:   \$${(precio ?? 0).toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                  ),
                ),

                const Spacer(),

                // Botón Finalizar
                FilledButton.icon(
                  onPressed: isActive
                      ? () async {
                          final now = DateTime.now().toUtc();
                          final minutes = now.difference(ingreso.toUtc()).inMinutes.clamp(1, 1000000);
                          final amount = (100 / 60.0) * minutes; // tarifa simple

                          await doc.update({
                            'egreso': Timestamp.fromDate(now),
                            'precioFinal': amount,
                            'status': 'closed',
                          });

                          if (context.mounted) {
                            // Evitar pop() en web: navegar directo
                            context.go('/history');
                          }
                        }
                      : null,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(isActive ? 'Finalizar' : 'Finalizado'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget simple que actualiza el tiempo transcurrido cada 1s.
class _LiveTimer extends StatefulWidget {
  final DateTime from;
  const _LiveTimer({required this.from});

  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  late Timer _t;
  late Duration _dur;

  @override
  void initState() {
    super.initState();
    _dur = DateTime.now().toUtc().difference(widget.from.toUtc());
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _dur = DateTime.now().toUtc().difference(widget.from.toUtc());
      });
    });
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = _dur.inHours.toString().padLeft(2, '0');
    final mm = (_dur.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (_dur.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        const Text('Tiempo transcurrido'),
        const SizedBox(height: 6),
        Text('$hh:$mm:$ss', style: Theme.of(context).textTheme.displaySmall),
      ],
    );
  }
}
