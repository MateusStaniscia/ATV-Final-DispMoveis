import '../../core/result/result.dart';
import '../entities/session_user.dart';
import '../repositories/auth_repository.dart';

class AuthenticateUseCase {
  final AuthRepository repository;
  const AuthenticateUseCase(this.repository);
  Future<Result<void>> call(Credentials credentials, {bool register = false}) {
    if (!RegExp(
          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
        ).hasMatch(credentials.email.trim()) ||
        credentials.password.length < 6) {
      return Future.value(
        Failure(
          ArgumentError('Credenciais inválidas'),
          'Informe e-mail válido e senha com pelo menos 6 caracteres.',
        ),
      );
    }
    return register
        ? repository.register(credentials)
        : repository.signIn(credentials);
  }
}

class GoogleLoginUseCase {
  final AuthRepository repository;
  const GoogleLoginUseCase(this.repository);
  Future<Result<void>> call() => repository.google();
}

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);
  Future<Result<void>> call() => repository.signOut();
}

class ObserveSessionUseCase {
  final AuthRepository repository;
  const ObserveSessionUseCase(this.repository);
  Stream<Result<SessionUser?>> call() => repository.session;
}

class ResetPasswordUseCase {
  final AuthRepository repository;
  const ResetPasswordUseCase(this.repository);
  Future<Result<void>> call(String email) =>
      repository.resetPassword(email.trim());
}
