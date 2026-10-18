import '../../core/result/result.dart';
import '../entities/session_user.dart';

abstract interface class AuthRepository {
  Stream<Result<SessionUser?>> get session;
  Future<Result<void>> signIn(Credentials credentials);
  Future<Result<void>> register(Credentials credentials);
  Future<Result<void>> google();
  Future<Result<void>> signOut();
  Future<Result<void>> resetPassword(String email);
}
