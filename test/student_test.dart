import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/core/result/result.dart';
import 'package:piramid_game/data/models/student_model.dart';
import 'package:piramid_game/domain/entities/student.dart';
import 'package:piramid_game/domain/entities/popularity_criteria.dart';
import 'package:piramid_game/domain/repositories/student_repository.dart';
import 'package:piramid_game/domain/usecases/save_student_usecase.dart';

class TestRepository extends Fake implements StudentRepository {
  Student? saved;
  @override
  Future<Result<void>> saveStudent(Student student) async {
    saved = student;
    return const Success(null);
  }
}

void main() {
  late TestRepository repo;
  late Student student;
  setUp(() {
    repo = TestRepository();
    student = Student(
      id: 'teste',
      name: ' Ana ',
      course: 'INFO',
      year: 2026,
      nickname: '',
      birthDate: DateTime(2000),
      scores: {for (final c in PopularityCriteria.values) c.id: 3},
    );
  });
  test('mapa NoSQL preserva os 15 critérios como mapa e a data ISO', () {
    final json = StudentModel.fromEntity(student).toJson();
    expect(json['scores'], isA<Map<String, int>>());
    final restored = StudentModel.fromJson(json);
    expect(restored.scores, student.scores);
    expect(restored.birthDate, student.birthDate);
    expect(restored.legendLevel, 45);
  });
  test('salva nome sem espaços nas extremidades', () async {
    expect(await SaveStudentUseCase(repo)(student), isA<Success<void>>());
    expect(repo.saved?.name, 'Ana');
  });
  test('impede dados incompatíveis com as regras antes da gravação', () async {
    for (final invalid in [
      student.copyWith(name: ' '),
      student.copyWith(name: 'a' * 121),
      student.copyWith(course: 'INVALIDO'),
      student.copyWith(year: 2027),
      student.copyWith(scores: {}),
      student.copyWith(scores: {...student.scores, 'aura': 6}),
      student.copyWith(birthDate: DateTime(2200)),
    ]) {
      expect(await SaveStudentUseCase(repo)(invalid), isA<Failure<void>>());
    }
    expect(repo.saved, null);
  });
}
