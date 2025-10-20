import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tp3_v2/domain/models/ticket_model.dart';

class TicketService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  Future<String> create(Ticket ticket) async {
    final ref = _db.collection('tickets').doc();
    await ref.set(ticket.toFirestore());
    return ref.id;
  }
}

