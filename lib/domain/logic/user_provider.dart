


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tp3_v2/domain/models/user_model.dart';

// Esta lógica se remplazara por un provider para solo un usuario
final usersProvider = StateNotifierProvider<UsersNotifier, Map<String, UserModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return UsersNotifier(firestore);
});


class UsersNotifier extends StateNotifier<Map<String, UserModel>> {
  final FirebaseFirestore _firestore;

  UsersNotifier(this._firestore) : super({}) {
    loadUsers();
  }

  // Carga inicial desde Firestore
  Future<void> loadUsers() async {
    final snapshot = await _firestore.collection('users').get();
    final usersMap = {
      for (var doc in snapshot.docs) doc.id: UserModel.fromFirestore(doc)
    };
    state = usersMap;    
  }

  Future<void> addUser(UserModel user) async {
    // Guarda en Firestore
    final docRef = await _firestore.collection('users').add(user.toFirestore());
    
    // Actualiza estado local (cache)
    state = {...state};
  }

  Future<void> removeUser(String id) async {
    await _firestore.collection('users').doc(id).delete();
    final newState = {...state}..remove(id);
    state = newState;
  }
}