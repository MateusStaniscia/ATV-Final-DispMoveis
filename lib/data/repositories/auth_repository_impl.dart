import 'dart:async';
import '../../core/result/result.dart';
import '../../domain/entities/session_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService service;
  final ProfileService profiles;
  AuthRepositoryImpl(this.service, this.profiles);
  @override
  Stream<Result<SessionUser?>> get session {
    late StreamController<Result<SessionUser?>> controller;
    StreamSubscription? subscription;
    var generation = 0;
    String? syncedUid;
    controller = StreamController(
      onListen: () {
        subscription = service.auth.idTokenChanges().listen(
          (user) async {
            final current = ++generation;
            if (user == null) {
              syncedUid = null;
              controller.add(const Success(null));
              return;
            }
            try {
              if (syncedUid != user.uid) {
                await profiles.sync(user).timeout(const Duration(seconds: 20));
              }
              if (controller.isClosed ||
                  current != generation ||
                  service.auth.currentUser?.uid != user.uid) {
                return;
              }
              syncedUid = user.uid;
              controller.add(
                Success(
                  SessionUser(
                    uid: user.uid,
                    email: user.email ?? '',
                    name: user.displayName ?? '',
                    photo: user.photoURL ?? '',
                    provider: user.providerData
                        .map((p) => p.providerId)
                        .join(','),
                  ),
                ),
              );
            } catch (e) {
              if (!controller.isClosed && current == generation) {
                controller.add(
                  Failure(
                    e,
                    'Não foi possível carregar seu perfil na nuvem. Entre novamente.',
                  ),
                );
              }
            }
          },
          onError: (Object e) {
            generation++;
            syncedUid = null;
            controller.add(
              Failure(
                e,
                'Sua sessão não pôde ser verificada. Entre novamente.',
              ),
            );
          },
        );
      },
      onCancel: () async {
        generation++;
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  Future<Result<void>> _run(Future<void> Function() action) async {
    try {
      await action();
      return const Success(null);
    } catch (e) {
      return Failure(e, AuthService.errorMessage(e));
    }
  }

  @override
  Future<Result<void>> signIn(Credentials c) =>
      _run(() => service.signIn(c.email, c.password));
  @override
  Future<Result<void>> register(Credentials c) =>
      _run(() => service.register(c.email, c.password));
  @override
  Future<Result<void>> google() => _run(service.google);
  @override
  Future<Result<void>> signOut() => _run(service.signOut);
  @override
  Future<Result<void>> resetPassword(String email) =>
      _run(() => service.resetPassword(email));
}
