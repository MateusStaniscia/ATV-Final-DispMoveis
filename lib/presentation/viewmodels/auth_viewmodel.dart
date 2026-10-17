import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/auth_service.dart';

/// O SDK restaura/renova a sessão; senhas e tokens não são copiados para preferências.
class AuthViewModel extends ChangeNotifier {
  final AuthService service;
  late final StreamSubscription<User?> _subscription;
  final void Function(String? uid) onSessionChanged;
  User? user;
  bool ready = false;
  bool busy = false;
  String? error;
  String? message;

  AuthViewModel(this.service, {required this.onSessionChanged}) {
    _subscription = service.auth.idTokenChanges().listen(
      (value) {
        if (!ready || user?.uid != value?.uid) onSessionChanged(value?.uid);
        user = value;
        ready = true;
        notifyListeners();
      },
      onError: (Object e) {
        user = null;
        ready = true;
        onSessionChanged(null);
        error = AuthService.errorMessage(e);
        notifyListeners();
      },
    );
  }
  Future<void> _run(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    message = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      error = AuthService.errorMessage(e);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) =>
      _run(() => service.signIn(email, password));
  Future<void> register(String email, String password) =>
      _run(() => service.register(email, password));
  Future<void> signOut() => _run(service.signOut);
  Future<void> resetPassword(String email) => _run(() async {
    await service.resetPassword(email);
    message =
        'Se houver uma conta para este e-mail, você receberá as instruções.';
  });
  void clearMessages() {
    error = null;
    message = null;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
