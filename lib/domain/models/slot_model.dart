import 'package:cloud_firestore/cloud_firestore.dart';

class Slot {
  final String? uid;       // ID generado por Firestore
  final String garageId;   // Ej: "B1", "C3"
  final String? vehicleId; // null si libre

  Slot({
    this.uid,
    required this.garageId,
    this.vehicleId,
  });

  /// 🔹 Factory para instanciar desde Firestore
  factory Slot.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Slot(
      uid: doc.id,
      garageId: data['garageId'] ?? '',
      vehicleId: data['vehicleId'],
    );
  }

  /// 🔹 Serialización a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      if (vehicleId != null) 'vehicleId': vehicleId,
    };
  }
}
