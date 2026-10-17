import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth;
  AuthService(this.auth);

  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(String email, String password) async {
    await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() => auth.signOut();

  static String errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-email' => 'Informe um e-mail válido.',
        'weak-password' => 'Use uma senha com pelo menos 6 caracteres.',
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'E-mail ou senha incorretos.',
        'user-disabled' => 'Esta conta foi desativada.',
        'network-request-failed' =>
          'Sem conexão. Verifique sua internet e tente novamente.',
        'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
        'operation-not-allowed' =>
          'Ative o login por e-mail e senha no Firebase Console.',
        _ => 'Não foi possível autenticar. Tente novamente.',
      };
    }
    return 'Não foi possível concluir a operação. Tente novamente.';
  }
}
