import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:tp3_v2/data/user_service.dart';
import 'package:tp3_v2/domain/models/user_model.dart';


class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final UserService _userService;

  AuthService (this._userService);

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  Future<fb.User?> signIn(String email, String password) async {
    try{
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );    

    print("credential.user en SignIn authService: ${credential.user}");
    return credential.user;
    } catch (e) {
      print (e.toString());
      throw e;
      
    }
  }

  Future<fb.User?> register(String email, String password) async {
    try{
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fb.User? fbUser = credential.user;
    if (fbUser == null) return null;

    final userModel = UserModel.initialFromAuth(
      uid: fbUser.uid,
      email: fbUser.email ?? email,
      );

    await _userService.addUser(userModel);
    return fbUser;
    }catch (e){
      print(e.toString());
      throw e;

    }
       
  }

  Future<void> signOut() => _auth.signOut();
}
