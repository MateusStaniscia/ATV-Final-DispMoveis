import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:go_router/go_router.dart';
import 'package:piramid_game/core/di.dart';
import 'package:piramid_game/core/result/result.dart';
import 'package:piramid_game/core/theme/app_theme.dart';
import 'package:piramid_game/domain/entities/campus.dart';
import 'package:piramid_game/domain/entities/session_user.dart';
import 'package:piramid_game/domain/entities/popularity_criteria.dart';
import 'package:piramid_game/domain/repositories/campus_repository.dart';
import 'package:piramid_game/domain/repositories/auth_repository.dart';
import 'package:piramid_game/domain/facades/auth_facade.dart';
import 'package:piramid_game/domain/facades/campus_facade.dart';
import 'package:piramid_game/domain/facades/theme_facade.dart';
import 'package:piramid_game/presentation/viewmodels/campus_viewmodel.dart';
import 'package:piramid_game/presentation/viewmodels/auth_viewmodel.dart';
import 'package:piramid_game/presentation/viewmodels/theme_viewmodel.dart';
import 'package:piramid_game/presentation/ui/home/home_screen.dart';
import 'package:piramid_game/presentation/ui/details/student_detail_screen.dart';
import 'package:piramid_game/presentation/ui/form/student_form_screen.dart';
import 'package:piramid_game/presentation/ui/evaluation/evaluation_screen.dart';

class MockTheme extends Fake implements ThemeFacade {}

class MockAuth extends Fake implements AuthRepository {
  @override
  Stream<Result<SessionUser?>> get session =>
      Stream.value(const Success(SessionUser(uid: 'alice')));
}

class MockCampus extends Fake implements CampusRepository {
  @override
  String get uid => 'alice';
  @override
  Future<Result<CampusData>> load() async => Success(
    CampusData(
      [
        Person(
          id: 'me',
          name: 'Meu perfil',
          nickname: '',
          course: 'TADS',
          year: 2026,
          birthDate: DateTime(2000),
          createdBy: 'alice',
          linkedUid: 'alice',
        ),
        Person(
          id: 'other',
          name: 'Outra pessoa',
          nickname: 'Teste',
          course: 'INFO',
          year: 2026,
          birthDate: DateTime(2000),
          createdBy: 'alice',
        ),
      ],
      [
        for (final entry in [('alice', 3), ('bob', 5)])
          Evaluation(
            evaluatorUid: entry.$1,
            personId: 'other',
            scores: {for (final c in PopularityCriteria.values) c.id: entry.$2},
            date: DateTime(2026),
          ),
      ],
      'me',
    ),
  );
}

void main() {
  late GoRouter router;
  setUp(() {
    campusViewModel = CampusViewModel(CampusFacade(MockCampus()));
    themeViewModel = ThemeViewModel(MockTheme());
    authViewModel = AuthViewModel(
      AuthFacade(MockAuth()),
      onSessionChanged: (_) {},
    );
  });
  tearDown(() {
    router.dispose();
    authViewModel.dispose();
  });
  Future<void> open(WidgetTester tester, String path) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    router = GoRouter(
      initialLocation: path,
      routes: [
        GoRoute(path: '/home', builder: (_, s) => const HomeScreen()),
        GoRoute(path: '/form', builder: (_, s) => const StudentFormScreen()),
        GoRoute(
          path: '/detail/:id',
          builder: (_, s) =>
              StudentDetailScreen(studentId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/evaluate/:id',
          builder: (_, s) =>
              EvaluationScreen(personId: s.pathParameters['id']!),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('detalhes sem histórico voltam ao início pela seta', (
    tester,
  ) async {
    await open(tester, '/detail/other');
    expect(router.canPop(), isFalse);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('detalhes preservam a tela anterior ao voltar', (tester) async {
    await open(tester, '/home');
    await tester.tap(find.text('Ranking Global'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Outra pessoa'));
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('60.0 pts'), findsOneWidget);
  });

  testWidgets('abas distinguem ranking pessoal e média global em tela móvel', (
    tester,
  ) async {
    await open(tester, '/home');
    expect(find.text('Outra pessoa'), findsOneWidget);
    await tester.tap(find.text('Ranking Pessoal'));
    await tester.pumpAndSettle();
    expect(find.text('45 pts'), findsOneWidget);
    await tester.tap(find.text('Ranking Global'));
    await tester.pumpAndSettle();
    expect(find.text('60.0 pts'), findsOneWidget);
    expect(find.textContaining('2 avaliações'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('perfil próprio não exibe avaliar e rota direta bloqueia', (
    tester,
  ) async {
    await open(tester, '/detail/me');
    expect(find.text('Avaliar pessoa'), findsNothing);
    router.go('/evaluate/me');
    await tester.pumpAndSettle();
    expect(find.textContaining('autoavaliação bloqueada'), findsOneWidget);
  });
  testWidgets('cadastro tem campos pessoais e não contém notas', (
    tester,
  ) async {
    await open(tester, '/form');
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Salvar pessoa'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'editar avaliação carrega notas anteriores e estrelas alteram total',
    (tester) async {
      await open(tester, '/evaluate/other');
      expect(find.text('Nível Lenda: 45 / 75'), findsOneWidget);
      await tester.tap(find.byTooltip('Resenha: 5 estrelas'));
      await tester.pump();
      expect(find.text('Nível Lenda: 47 / 75'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
