import 'dart:async';
import 'package:piramid_game/core/result/result.dart';
import 'package:piramid_game/domain/entities/session_user.dart';
import 'package:piramid_game/domain/repositories/auth_repository.dart';
import 'package:piramid_game/domain/facades/auth_facade.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/presentation/viewmodels/auth_viewmodel.dart';
import 'package:piramid_game/presentation/ui/auth/login_screen.dart';

class TestService extends Fake implements AuthRepository {
  final stream = StreamController<Result<SessionUser?>>.broadcast();
  int signInCalls = 0, registerCalls = 0, googleCalls = 0;
  bool fail = false;
  @override
  Stream<Result<SessionUser?>> get session => stream.stream;
  @override
  Future<Result<void>> signIn(Credentials credentials) async {
    signInCalls++;
    return fail
        ? Failure(StateError('invalid'), 'E-mail ou senha incorretos.')
        : const Success(null);
  }

  @override
  Future<Result<void>> register(Credentials credentials) async {
    registerCalls++;
    return const Success(null);
  }

  @override
  Future<Result<void>> google() async {
    googleCalls++;
    return const Success(null);
  }

  @override
  Future<Result<void>> signOut() async {
    stream.add(const Success(null));
    return const Success(null);
  }
}

void main() {
  late TestService service;
  late AuthViewModel model;
  late List<String?> sessions;
  setUp(() {
    service = TestService();
    sessions = [];
    model = AuthViewModel(AuthFacade(service), onSessionChanged: sessions.add);
  });
  tearDown(() async {
    model.dispose();
    await service.stream.close();
  });
  test('aguarda SDK, restaura usuário e limpa sessão ao sair', () async {
    expect(model.ready, false);
    service.stream.add(const Success(SessionUser(uid: 'alice')));
    await Future<void>.delayed(Duration.zero);
    expect(model.ready, true);
    expect(model.user?.uid, 'alice');
    service.stream.add(
      const Success(SessionUser(uid: 'alice')),
    ); // refresh não recria os dados
    await Future<void>.delayed(Duration.zero);
    expect(sessions, ['alice']);
    await model.signOut();
    await Future<void>.delayed(Duration.zero);
    expect(model.user, null);
    expect(sessions, ['alice', null]);
  });
  test('erro no stream fecha acesso e limpa dados', () async {
    service.stream.add(const Success(SessionUser(uid: 'alice')));
    await Future<void>.delayed(Duration.zero);
    service.stream.addError(StateError('session failure'));
    await Future<void>.delayed(Duration.zero);
    expect(model.user, null);
    expect(model.error, contains('verificada'));
    expect(sessions.last, null);
  });
  testWidgets('Google usa o comando da ViewModel', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(model: model)));
    await tester.tap(find.text('Entrar com Google'));
    await tester.pumpAndSettle();
    expect(service.googleCalls, 1);
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
