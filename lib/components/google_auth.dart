import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['openid', 'email']);

  Future<String?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Inici de sessió cancel·lat per l’usuari');
    }

    final googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null || googleAuth.accessToken == null) {
      throw Exception('No s’ha pogut obtenir els tokens de Google');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('No s’ha pogut obtenir l’usuari de Firebase');
    }

    final firebaseIdToken = await user.getIdToken();
    return firebaseIdToken;
  }
}
