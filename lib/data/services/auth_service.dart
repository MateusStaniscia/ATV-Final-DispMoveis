import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth;
  AuthService(this.auth);

  Future<void>? _googleInitialization;
  Future<void> google() async {
    if (kIsWeb) {
      await auth.signInWithPopup(
        GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'}),
      );
    } else {
      const clientId = String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue:
            '280712703203-ilu3u2lfitc5ulqdng0h2eljh81mp4v0.apps.googleusercontent.com',
      );
      _googleInitialization ??= GoogleSignIn.instance.initialize(
        serverClientId: clientId.isEmpty ? null : clientId,
      );
      await _googleInitialization;
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null) throw StateError('Google não retornou um token.');
      await auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: token),
      );
    }
  }

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
    if (error is GoogleSignInException) {
      return 'Login Google cancelado ou indisponível. Confira a configuração Google do aplicativo.';
    }
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
          'Ative este provedor de login no Firebase Console.',
        _ => 'Não foi possível autenticar. Tente novamente.',
      };
    }
    return 'Não foi possível concluir a operação. Tente novamente.';
  }
}
