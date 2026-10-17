import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/data/services/auth_service.dart';
import 'package:piramid_game/presentation/viewmodels/auth_viewmodel.dart';
import 'package:piramid_game/presentation/ui/auth/login_screen.dart';

class TestUser extends Fake implements User {
  @override
  final String uid;
  TestUser(this.uid);
}

class TestAuth extends Fake implements FirebaseAuth {
  final stream = StreamController<User?>.broadcast();
  @override
  Stream<User?> idTokenChanges() => stream.stream;
}

class TestService extends AuthService {
  int signInCalls = 0;
  int registerCalls = 0;
  bool fail = false;
  TestService(super.auth);
  @override
  Future<void> signIn(String email, String password) async {
    signInCalls++;
    if (fail) throw FirebaseAuthException(code: 'invalid-credential');
  }

  @override
  Future<void> register(String email, String password) async {
    registerCalls++;
  }

  @override
  Future<void> signOut() async {
    (auth as TestAuth).stream.add(null);
  }
}

void main() {
  late TestAuth auth;
  late TestService service;
  late AuthViewModel model;
  late List<String?> sessions;
  setUp(() {
    auth = TestAuth();
    service = TestService(auth);
    sessions = [];
    model = AuthViewModel(service, onSessionChanged: sessions.add);
  });
  tearDown(() async {
    model.dispose();
    await auth.stream.close();
  });
  test('aguarda SDK, restaura usuário e limpa sessão ao sair', () async {
    expect(model.ready, false);
    auth.stream.add(TestUser('alice'));
    await Future<void>.delayed(Duration.zero);
    expect(model.ready, true);
    expect(model.user?.uid, 'alice');
    auth.stream.add(TestUser('alice')); // refresh não recria os dados
    await Future<void>.delayed(Duration.zero);
    expect(sessions, ['alice']);
    await model.signOut();
    await Future<void>.delayed(Duration.zero);
    expect(model.user, null);
    expect(sessions, ['alice', null]);
  });
  test('erro no stream fecha acesso e limpa dados', () async {
    auth.stream.add(TestUser('alice'));
    await Future<void>.delayed(Duration.zero);
    auth.stream.addError(FirebaseAuthException(code: 'user-disabled'));
    await Future<void>.delayed(Duration.zero);
    expect(model.user, null);
    expect(model.error, contains('desativada'));
    expect(sessions.last, null);
  });
  testWidgets('login valida campos antes de chamar Firebase', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(model: model)));
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(service.signInCalls, 0);
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
  });
  testWidgets('cadastro exige confirmação igual à senha', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(model: model)));
    await tester.tap(find.text('Criar uma conta'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'aluno@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
    await tester.enterText(find.byType(TextFormField).at(2), 'diferente');
    await tester.tap(find.text('Criar conta'));
    await tester.pump();
    expect(service.registerCalls, 0);
    expect(find.text('As senhas não coincidem.'), findsOneWidget);
  });
  testWidgets('erro de credencial aparece sem liberar a sessão', (
    tester,
  ) async {
    service.fail = true;
    await tester.pumpWidget(MaterialApp(home: LoginScreen(model: model)));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'aluno@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(service.signInCalls, 1);
    expect(model.user, null);
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
  });
}
