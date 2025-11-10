// lib/presentation/screens/active_session_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_scaffold.dart';

class ActiveSessionScreen extends StatelessWidget {
  final String? ticketId;
  const ActiveSessionScreen({super.key, this.ticketId});

  @override
  Widget build(BuildContext context) {
    // Si entran sin id -> placeholder (compat con /active)
    if (ticketId == null) {
      return const AppScaffold(
        title: 'Estadía activa',
        body: Center(child: Text('No hay estadía activa seleccionada.')),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const AppScaffold(
        title: 'Estadía activa',
        body: Center(child: Text('Iniciá sesión para ver tu estadía.')),
      );
    }

    final docRef =
        FirebaseFirestore.instance.collection('tickets').doc(ticketId);

    return AppScaffold(
      title: 'Estadía activa',
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Ticket no encontrado'));
          }

          final data = snap.data!.data()!;
          final plate = (data['vehiclePlate'] ?? data['plate'] ?? '') as String;
          final status = (data['status'] ?? '').toString().toLowerCase();
          final ingreso = (data['ingreso'] as Timestamp?)?.toDate();
          final isActive = status == 'active' || status == 'activo';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.local_parking_rounded,
                          color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patente: ${plate.isEmpty ? '—' : plate}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (ingreso != null)
                            Text(
                              'Inicio: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(ingreso.toLocal())}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'ACTIVO' : status.toUpperCase(),
                        style: TextStyle(
                          color: isActive ? Colors.green[900] : Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Timer
              if (ingreso != null) _ElapsedBox(start: ingreso),

              // Espacio final para respirar (no hay botón en Cliente)
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _ElapsedBox extends StatefulWidget {
  final DateTime start;
  const _ElapsedBox({required this.start});

  @override
  State<_ElapsedBox> createState() => _ElapsedBoxState();
}

class _ElapsedBoxState extends State<_ElapsedBox> {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.start);
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration _) {
    if (!mounted) return;
    setState(() {
      _elapsed = DateTime.now().difference(widget.start);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(_elapsed.inHours);
    final m = two(_elapsed.inMinutes.remainder(60));
    final s = two(_elapsed.inSeconds.remainder(60));

    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tiempo transcurrido',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              '$h:$m:$s',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini ticker sin dependencias externas
class Ticker {
  Ticker(this.onTick);
  final void Function(Duration) onTick;
  Duration _elapsed = Duration.zero;
  late final Stopwatch _sw = Stopwatch();
  bool _running = false;

  void start() {
    _running = true;
    _sw.start();
    _tick();
  }

  Future<void> _tick() async {
    while (_running) {
      await Future<void>.delayed(const Duration(seconds: 1));
      _elapsed = _sw.elapsed;
      onTick(_elapsed);
    }
  }

  void dispose() {
    _running = false;
  }
}
