import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ¡Importante! Aquí se definen todos los scopes que tu aplicación necesitará.
  final List<String> _googleCalendarScopes = [
    'openid',
    'email',
    // ANTES: gcal.CalendarApi.calendarAppCreatedScope, // Este solo es para calendarios creados por la app
    // AHORA: Usa el scope completo para lectura y escritura en el calendario del usuario
    gcal.CalendarApi.calendarScope, // <-- ¡CAMBIO CRÍTICO AQUÍ!
  ];

  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // Inicializa GoogleSignIn con TODOS los scopes necesarios.
    _googleSignIn = GoogleSignIn(scopes: _googleCalendarScopes);
  }

  // Este método inicia sesión con Google y autentica en Firebase.
  // Devuelve el ID Token de Firebase para tu backend/autenticación en la app.
  Future<String?> signInWithGoogle() async {
    try {
      // Intenta iniciar sesión con Google. Esto abrirá la ventana de consentimiento si es necesario.
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Inici de sessió cancel·lat per l’usuari');
      }

      // Obtiene los detalles de autenticación de Google (tokens).
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        throw Exception('No s’ha pogut obtenir els tokens de Google');
      }

      // Crea una credencial de Firebase con los tokens de Google.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión en Firebase con la credencial.
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('No s’ha pogut obtenir l’usuari de Firebase');
      }

      // Devuelve el ID Token de Firebase para tu uso interno en la app o backend.
      final firebaseIdToken = await user.getIdToken();
      return firebaseIdToken;
    } catch (e) {
      print('Error al iniciar sessió amb Google: $e');
      rethrow; // Propaga el error para que la UI pueda manejarlo.
    }
  }

  // Cierra la sesión tanto de Google como de Firebase.
  Future<void> signOut() async {
    await _googleSignIn
        .signOut(); // Cierra la sesión de Google (borra cookies, etc.)
    await _auth.signOut(); // Cierra la sesión de Firebase
    print('Sessió tancada correctament.');
  }

  // ¡Este es el método CRUCIAL para interactuar con las APIs de Google (como Calendar)!
  // Devuelve un cliente HTTP autenticado con los permisos de Google.
  Future<AuthClient?> getAuthenticatedClient() async {
    GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
    if (googleUser == null) {
      googleUser =
          await _googleSignIn.signInSilently(); // <-- Esto gestiona el refresh
      if (googleUser == null) {
        print(
          'No hay sesión de Google activa o no se pudo refrescar silenciosamente para obtener AuthClient.',
        );
        return null;
      }
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    if (googleAuth.accessToken == null) {
      print('AccessToken nulo. El usuario debe volver a autenticarse.');
      return null;
    }

    final AccessToken accessToken = AccessToken(
      'Bearer',
      googleAuth.accessToken!,
      DateTime.now().toUtc().add(Duration(hours: 1)), // Expiración estimada
    );

    final AccessCredentials credentials = AccessCredentials(
      accessToken,
      null, // refreshToken, which you may not have
      _googleCalendarScopes,
    );

    return authenticatedClient(http.Client(), credentials);
  }
}
