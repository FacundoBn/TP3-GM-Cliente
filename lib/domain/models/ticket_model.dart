import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String? uid;       // ID Firestore
  final String vehicleId;
  final String userId;
  final String? guestId;
  final String slotId;
  final DateTime ingreso;
  final DateTime? egreso;
  final double? precioFinal;

  // 🔹 Datos redundantes para facilitar la UI
  final String vehiclePlate;
  final String vehicleTipo;       // moto, auto, camioneta
  final String userNombre;
  final String userApellido;
  final String userEmail;
  final String slotGarageId;

  Ticket({
    this.uid,
    required this.vehicleId,
    required this.userId,
    this.guestId,
    required this.slotId,
    required this.ingreso,
    this.egreso,
    this.precioFinal,
    required this.vehiclePlate,
    required this.vehicleTipo,
    required this.userNombre,
    required this.userApellido,
    required this.userEmail,
    required this.slotGarageId,
  });

  /// 🔹 Factory para reconstruir desde Firestore
  factory Ticket.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Ticket(
      uid: doc.id,
      vehicleId: data['vehicleId'] as String,
      userId: data['userId'] as String,
      guestId: data['guestId'] as String?,
      slotId: data['slotId'] as String,
      ingreso: (data['ingreso'] as Timestamp).toDate(),
      egreso: data['egreso'] != null ? (data['egreso'] as Timestamp).toDate() : null,
      precioFinal: data['precioFinal'] != null ? (data['precioFinal'] as num).toDouble() : null,
      vehiclePlate: data['vehiclePlate'] as String? ?? '',
      vehicleTipo: data['vehicleTipo'] as String? ?? 'auto',
      userNombre: data['userNombre'] as String? ?? '',
      userApellido: data['userApellido'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      slotGarageId: data['slotGarageId'] as String? ?? '',
    );
  }

  /// 🔹 Serialización a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      if (guestId != null) 'guestId': guestId,
      'slotId': slotId,
      'ingreso': Timestamp.fromDate(ingreso),
      if (egreso != null) 'egreso': Timestamp.fromDate(egreso!),
      if (precioFinal != null) 'precioFinal': precioFinal,
      // 🔹 Datos redundantes
      'vehiclePlate': vehiclePlate,
      'vehicleTipo': vehicleTipo,
      'userNombre': userNombre,
      'userApellido': userApellido,
      'userEmail': userEmail,
      'slotGarageId': slotGarageId,
    };
  }
}
