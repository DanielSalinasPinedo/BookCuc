import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para obtener el estado de la sesión del usuario
  Stream<User?> get userStream => _auth.authStateChanges();

  // Método para obtener el correo electrónico del usuario actual
  String? getCurrentUserEmail() {
    User? user = _auth.currentUser;
    return user?.email;
  }

  // Método para iniciar sesión con correo electrónico y contraseña
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      // Manejar errores de inicio de sesión
      print('Error al iniciar sesión: $e');
      throw e;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Manejar errores al cerrar sesión
      print('Error al cerrar sesión: $e');
      throw e;
    }
  }
}
