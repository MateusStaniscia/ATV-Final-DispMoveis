import '../repositories/auth_repository.dart';
import '../usecases/auth_usecases.dart';

class AuthFacade {
  final AuthenticateUseCase authenticate;
  final GoogleLoginUseCase google;
  final LogoutUseCase logout;
  final ObserveSessionUseCase observe;
  final ResetPasswordUseCase reset;
  AuthFacade(AuthRepository repo)
    : authenticate = AuthenticateUseCase(repo),
      google = GoogleLoginUseCase(repo),
      logout = LogoutUseCase(repo),
      observe = ObserveSessionUseCase(repo),
      reset = ResetPasswordUseCase(repo);
}
