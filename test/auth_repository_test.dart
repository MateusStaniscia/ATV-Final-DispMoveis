import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:piramid_game/core/result/result.dart';
import 'package:piramid_game/domain/entities/session_user.dart';
import 'package:piramid_game/data/repositories/auth_repository_impl.dart';
import 'package:piramid_game/data/services/auth_service.dart';
import 'package:piramid_game/data/services/profile_service.dart';

class FakeUser extends Fake implements User {
  @override
  String get uid => 'alice';
  @override
  String? get email => 'alice@example.com';
  @override
  String? get displayName => null;
  @override
  String? get photoURL => null;
  @override
  List<UserInfo> get providerData => [];
}

class FakeAuth extends Fake implements FirebaseAuth {
  final events = StreamController<User?>.broadcast();
  User? current;
  @override
  User? get currentUser => current;
  @override
  Stream<User?> idTokenChanges() => events.stream;
  void emit(User? value) {
    current = value;
    events.add(value);
  }
}

class FakeDb extends Fake implements FirebaseFirestore {}

class DelayedProfile extends ProfileService {
  final pending = Completer<void>();
  DelayedProfile(FakeAuth auth) : super(FakeDb(), auth);
  @override
  Future<void> sync(User user) => pending.future;
}

void main() {
  test(
    'logout não espera perfil remoto e resposta antiga não reabre a sessão',
    () async {
      final auth = FakeAuth(), results = <Result<SessionUser?>>[];
      final profiles = DelayedProfile(auth);
      final repo = AuthRepositoryImpl(AuthService(auth), profiles);
      final subscription = repo.session.listen(results.add);
      auth.emit(FakeUser());
      await Future<void>.delayed(Duration.zero);
      auth.emit(null);
      await Future<void>.delayed(Duration.zero);
      expect(results.length, 1);
      expect(results.single.getOrThrow(), null);
      profiles.pending.complete();
      await Future<void>.delayed(Duration.zero);
      expect(results.length, 1);
      await subscription.cancel();
      await auth.events.close();
    },
  );
}
