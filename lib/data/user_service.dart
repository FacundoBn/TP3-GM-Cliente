import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  UserService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Crea o complementa users/{uid}. Si no tiene rol, asigna ["cliente"].
  Future<void> ensureClientUserDoc(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'roleIds': ['cliente'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final data = snap.data() as Map<String, dynamic>;
    final existingRoles = (data['roleIds'] as List?)?.cast<String>() ?? const [];
    final needRole = existingRoles.isEmpty;

    await ref.set({
      if ((data['email'] as String?)?.isEmpty ?? true) 'email': user.email ?? '',
      if ((data['displayName'] as String?)?.isEmpty ?? true) 'displayName': user.displayName ?? '',
      if (needRole) 'roleIds': ['cliente'],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// === FIRMA QUE ESPERA TU current_user_provider.dart ===
  /// (lo usa para leer el doc del usuario actual)
  Future<Map<String, dynamic>?> currentUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.data();
  }

  /// Útil si en algún lado querés escuchar cambios del doc del usuario
  Stream<Map<String, dynamic>?> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((s) => s.data());
  }
}
