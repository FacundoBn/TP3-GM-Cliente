import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/domain/logic/current_user_provider.dart';
import 'package:tp3_v2/domain/logic/vehicle_provider.dart';

class UserVehiclesScreen extends ConsumerWidget {
  final String? userUid; // Opcional: si no se pasa, tomamos el currentUser

  const UserVehiclesScreen({super.key, this.userUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👇 Determinamos el UID a usar
    final effectiveUserUid = userUid ?? ref.watch(currentUserProvider).value?.uid;

    if (effectiveUserUid == null) {
      return const Center(child: Text('No hay sesión activa'));
    }

    final vehiclesAsync = ref.watch(userVehiclesProvider(effectiveUserUid));
    
      return vehiclesAsync.when(
          data: (vehicles){
            if (vehicles.isEmpty){
              return const Center(child: Text("NO hay vehículos registrados"));
            }
            return ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(vehicles[i].plate),
                subtitle: Text(vehicles[i].tipo.name),
              ),
            );
          },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      );
    }
}
