import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
    UserService? userService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance,
        _userService = userService ?? UserService(db: db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final UserService _userService;

  /// === FIRMA COMPATIBLE CON TU CÓDIGO EXISTENTE ===
  /// Tu UI llama: authService.signIn(email, pass)
  Future<UserCredential> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Garantiza users/{uid} con rol "cliente" al primer ingreso
    await _userService.ensureClientUserDoc(cred.user!);
    return cred;
  }

  /// Tu UI llama: authService.register(email, pass)
  Future<UserCredential> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Crea/mergea el doc users/{uid} con roleIds:["cliente"]
    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email.trim(),
      'displayName': cred.user!.displayName ?? '',
      'roleIds': ['cliente'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return cred;
  }

  /// Stream de auth para tu AuthGate (compatibilidad)
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signOut() => _auth.signOut();

  /// Por si la app ya abre con un user logueado
  Future<void> ensureClientDocForCurrentUser() async {
    final u = _auth.currentUser;
    if (u != null) await _userService.ensureClientUserDoc(u);
  }
}
