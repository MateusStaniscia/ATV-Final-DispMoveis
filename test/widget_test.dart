import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:piramid_game/domain/entities/campus.dart';
import 'package:piramid_game/domain/entities/popularity_criteria.dart';
import 'package:piramid_game/domain/usecases/campus_usecases.dart';

Person person(String id, String name, {bool active = true}) => Person(
  id: id,
  name: name,
  nickname: '',
  course: 'TADS',
  year: 2026,
  birthDate: DateTime(2000),
  createdBy: 'admin',
  active: active,
);
Evaluation rating(String uid, String id, int total) {
  var remaining = total - 15;
  final scores = <String, int>{};
  for (final c in PopularityCriteria.values) {
    final extra = remaining.clamp(0, 4);
    scores[c.id] = 1 + extra;
    remaining -= extra;
  }
  return Evaluation(
    evaluatorUid: uid,
    personId: id,
    scores: scores,
    date: DateTime(2026),
  );
}

void main() {
  const rank = CalculateRankingsUseCase();
  test('global usa média 60,70,65 = 65 e quantidade recebida', () {
    final data = CampusData(
      [person('ana', 'Ana')],
      [rating('a', 'ana', 60), rating('b', 'ana', 70), rating('c', 'ana', 65)],
      null,
    );
    final result = rank(data).getOrThrow();
    expect(result.single.average, 65);
    expect(result.single.count, 3);
  });
  test('ranking pessoal não sofre influência de outros usuários', () {
    final data = CampusData(
      [person('ana', 'Ana'), person('bia', 'Bia')],
      [rating('a', 'ana', 30), rating('b', 'ana', 75), rating('a', 'bia', 60)],
      null,
    );
    expect(rank(data, evaluatorUid: 'a').getOrThrow().map((r) => r.person.id), [
      'bia',
      'ana',
    ]);
    expect(rank(data, evaluatorUid: 'a').getOrThrow().last.average, 30);
  });
  test('global ordena por média, não pelo número ou soma das avaliações', () {
    final data = CampusData(
      [person('a', 'A'), person('b', 'B')],
      [rating('u1', 'a', 30), rating('u2', 'a', 30), rating('u1', 'b', 45)],
      null,
    );
    expect(rank(data).getOrThrow().first.person.id, 'b');
  });
  test('empate alfabético e pessoas sem notas ou removidas não entram', () {
    final data = CampusData(
      [
        person('z', 'Zeca'),
        person('a', 'ana'),
        person('x', 'Sem notas'),
        person('r', 'Removido', active: false),
      ],
      [rating('u', 'z', 45), rating('u', 'a', 45), rating('u', 'r', 75)],
      null,
    );
    expect(rank(data).getOrThrow().map((r) => r.person.id), ['a', 'z']);
  });
  test('todos os critérios possuem escala completa de 15 a 75', () {
    expect(rating('u', 'a', 15).total, 15);
    expect(rating('u', 'a', 75).total, 75);
    expect(PopularityCriteria.values.length, 15);
  });
}
