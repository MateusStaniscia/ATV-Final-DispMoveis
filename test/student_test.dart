import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:piramid_game/core/result/result.dart';
import 'package:piramid_game/domain/entities/campus.dart';
import 'package:piramid_game/domain/entities/popularity_criteria.dart';
import 'package:piramid_game/domain/repositories/campus_repository.dart';
import 'package:piramid_game/domain/usecases/campus_usecases.dart';

class Repo extends Fake implements CampusRepository {
  @override
  String get uid => 'alice';
  Person? saved;
  int evaluations = 0;
  @override
  Future<Result<void>> savePerson(Person p) async {
    saved = p;
    return const Success(null);
  }

  @override
  Future<Result<void>> saveEvaluation(Evaluation e) async {
    evaluations++;
    return const Success(null);
  }
}

Person person({
  String name = ' Ana ',
  String course = 'TADS',
  int year = 2026,
  String? linkedUid,
  DateTime? birthDate,
}) => Person(
  id: 'p',
  name: name,
  nickname: '',
  course: course,
  year: year,
  birthDate: birthDate ?? DateTime(2000),
  createdBy: 'alice',
  linkedUid: linkedUid,
);
void main() {
  late Repo repo;
  setUp(() => repo = Repo());
  test('perfil é cadastrado sem notas ou conta de autenticação', () async {
    expect(await SavePersonUseCase(repo)(person()), isA<Success<void>>());
    expect(repo.saved!.name, 'Ana');
  });
  test('perfil valida nome, curso, ano e nascimento', () async {
    for (final p in [
      person(name: ' '),
      person(name: 'x' * 121),
      person(course: 'BAD'),
      person(year: 2027),
      person(birthDate: DateTime(2200)),
    ]) {
      expect(await SavePersonUseCase(repo)(p), isA<Failure<void>>());
    }
    expect(repo.saved, null);
  });
  test('autoavaliação e autoria falsa são bloqueadas no use case', () async {
    for (final uid in ['alice', 'bob']) {
      final e = Evaluation(
        evaluatorUid: uid,
        personId: 'p',
        scores: {for (final c in PopularityCriteria.values) c.id: 3},
        date: DateTime.now(),
      );
      expect(
        await SaveEvaluationUseCase(repo)(e, person(linkedUid: 'alice')),
        isA<Failure<void>>(),
      );
    }
    expect(repo.evaluations, 0);
  });
  test('faltas, extras e notas fora de 1 a 5 são rejeitadas', () async {
    final valid = {for (final c in PopularityCriteria.values) c.id: 3};
    for (final s in [
      <String, int>{},
      {...valid, 'aura': 0},
      {...valid, 'aura': 6},
      {...valid, 'extra': 3},
    ]) {
      expect(
        await SaveEvaluationUseCase(repo)(
          Evaluation(
            evaluatorUid: 'alice',
            personId: 'p',
            scores: s,
            date: DateTime.now(),
          ),
          person(),
        ),
        isA<Failure<void>>(),
      );
    }
  });
  test('avaliação válida segue ao repositório', () async {
    final e = Evaluation(
      evaluatorUid: 'alice',
      personId: 'p',
      scores: {for (final c in PopularityCriteria.values) c.id: 3},
      date: DateTime.now(),
    );
    expect(
      await SaveEvaluationUseCase(repo)(e, person()),
      isA<Success<void>>(),
    );
    expect(repo.evaluations, 1);
  });
}
