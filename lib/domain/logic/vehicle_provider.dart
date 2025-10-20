import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tp3_v2/data/vehicle_service.dart';
import 'package:tp3_v2/domain/models/vehicle_model.dart';

final vehicleServiceProvider = Provider<VehicleService>((ref)
  {return VehicleService();
});

final userVehiclesProvider = StreamProvider.family<List<Vehicle>,String>((ref, userUid){
  final service = ref.watch(vehicleServiceProvider);
  
  return service.fetchVehiclesForUser(userUid);
});