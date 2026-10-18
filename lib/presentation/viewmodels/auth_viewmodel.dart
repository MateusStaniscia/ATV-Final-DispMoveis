import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command/command.dart';
import '../../core/result/result.dart';
import '../../domain/entities/session_user.dart';
import '../../domain/facades/auth_facade.dart';

/// ChangeNotifier é apenas a ponte para o GoRouter; o estado é mantido em Signals.
class AuthViewModel extends ChangeNotifier {
  final AuthFacade facade;
  final void Function(String? uid) onSessionChanged;
  final userSignal = signal<SessionUser?>(null);
  final readySignal = signal(false);
  final busySignal = signal(false);
  final errorSignal = signal<String?>(null);
  final messageSignal = signal<String?>(null);
  SessionUser? get user => userSignal.value;
  bool get ready => readySignal.value;
  bool get busy => busySignal.value;
  String? get error => errorSignal.value;
  String? get message => messageSignal.value;
  late final StreamSubscription<Result<SessionUser?>> _subscription;
  late final CommandWithParam<void, Credentials> loginCommand, registerCommand;
  late final Command<void> loginGoogleCommand, logoutCommand;
  late final CommandWithParam<void, String> resetPasswordCommand;
  bool _disposed = false;
  AuthViewModel(this.facade, {required this.onSessionChanged}) {
    loginCommand = CommandWithParam((c) => _run(() => facade.authenticate(c)));
    registerCommand = CommandWithParam(
      (c) => _run(() => facade.authenticate(c, register: true)),
    );
    loginGoogleCommand = Command(() => _run(facade.google.call));
    logoutCommand = Command(() => _run(facade.logout.call));
    resetPasswordCommand = CommandWithParam(
      (email) => _run(() async {
        final result = await facade.reset(email);
        if (result is Success<void>) {
          messageSignal.value =
              'Se houver uma conta para este e-mail, você receberá as instruções.';
        }
        return result;
      }),
    );
    _subscription = facade.observe().listen(
      (result) {
        if (_disposed) return;
        result.when(
          onSuccess: (value) {
            if (!ready || user?.uid != value?.uid) onSessionChanged(value?.uid);
            userSignal.value = value;
          },
          onFailure: (e, msg) {
            userSignal.value = null;
            onSessionChanged(null);
            errorSignal.value = msg;
          },
        );
        readySignal.value = true;
        notifyListeners();
      },
      onError: (Object error) {
        if (_disposed) return;
        userSignal.value = null;
        readySignal.value = true;
        onSessionChanged(null);
        errorSignal.value =
            'Sua sessão não pôde ser verificada. Entre novamente.';
        notifyListeners();
      },
    );
  }
  Future<Result<void>> _run(Future<Result<void>> Function() action) async {
    if (busy) return Failure(StateError('Aguarde a operação atual.'));
    busySignal.value = true;
    clearMessages();
    notifyListeners();
    try {
      final result = await action();
      if (!_disposed && result is Failure<void>) {
        errorSignal.value = result.message;
      }
      return result;
    } finally {
      if (!_disposed) {
        busySignal.value = false;
        notifyListeners();
      }
    }
  }

  Future<void> signIn(String email, String password) async =>
      loginCommand.execute(Credentials(email, password));
  Future<void> register(String email, String password) async =>
      registerCommand.execute(Credentials(email, password));
  Future<void> signOut() async => logoutCommand.execute();
  Future<void> resetPassword(String email) async =>
      resetPasswordCommand.execute(email);
  void clearMessages() {
    errorSignal.value = null;
    messageSignal.value = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
