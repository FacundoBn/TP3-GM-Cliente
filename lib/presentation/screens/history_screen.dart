import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tp3_v2/domain/logic/current_user_provider.dart';
import 'package:tp3_v2/domain/logic/ticket_provider.dart';
import 'package:tp3_v2/domain/logic/vehicle_provider.dart';
import 'package:tp3_v2/presentation/widgets/app_scaffold.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _selectedPlate;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('No hay usuario')));
    }

    /* ==========  AsyncValue  ========== */
    final asyncPlates = ref.watch(userVehiclesProvider(currentUser.uid));

    return AppScaffold(
      title: 'Historial',
      body: asyncPlates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (plates) {
          // <-- plates es List<String> des-envuelto
          if (plates.isEmpty) {
            return const Center(child: Text('Sin vehículos'));
          }

          // valor inicial sólo cuando hay data
          _selectedPlate ??= plates.first.plate;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona una patente:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Elige una patente'),
                  value: _selectedPlate,
                  items: plates.map((p) {
                    return DropdownMenuItem(
                      value: p.plate, 
                      child: Text(p.plate));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedPlate = val);
                    if (val != null) context.go('/history/$val');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}