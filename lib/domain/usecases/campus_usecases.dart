import '../../core/result/result.dart';
import '../entities/campus.dart';
import '../repositories/campus_repository.dart';

class LoadCampusUseCase {
  final CampusRepository repository;
  const LoadCampusUseCase(this.repository);
  Future<Result<CampusData>> call() => repository.load();
}

class SavePersonUseCase {
  final CampusRepository repository;
  const SavePersonUseCase(this.repository);
  Future<Result<void>> call(Person person) {
    if (person.name.trim().isEmpty ||
        person.name.trim().length > 120 ||
        person.nickname.trim().length > 60 ||
        ![
          'INFO',
          'MEC',
          'MAMB',
          'PROD',
          'TADS',
          'TGA',
        ].contains(person.course) ||
        person.year < 1998 ||
        person.year > 2026 ||
        person.birthDate.isAfter(DateTime.now()) ||
        person.birthDate.year < 1900) {
      return Future.value(
        Failure(
          ArgumentError('Perfil inválido'),
          'Revise nome, apelido, curso, ano e nascimento.',
        ),
      );
    }
    return repository.savePerson(
      Person(
        id: person.id,
        name: person.name.trim(),
        nickname: person.nickname.trim(),
        course: person.course,
        year: person.year,
        birthDate: person.birthDate,
        createdBy: person.createdBy,
        linkedUid: person.linkedUid,
        active: person.active,
      ),
    );
  }
}

class RemovePersonUseCase {
  final CampusRepository repository;
  const RemovePersonUseCase(this.repository);
  Future<Result<void>> call(String id) => repository.removePerson(id);
}

class LinkPersonUseCase {
  final CampusRepository repository;
  const LinkPersonUseCase(this.repository);
  Future<Result<void>> call(String id) => repository.linkPerson(id);
}

class SaveEvaluationUseCase {
  final CampusRepository repository;
  const SaveEvaluationUseCase(this.repository);
  Future<Result<void>> call(Evaluation evaluation, Person person) {
    if (evaluation.evaluatorUid != repository.uid ||
        evaluation.personId != person.id ||
        person.linkedUid == repository.uid ||
        !person.active ||
        !evaluation.valid) {
      return Future.value(
        Failure(
          ArgumentError('Avaliação inválida'),
          'Não é permitido avaliar a si próprio. Preencha os 15 critérios de 1 a 5.',
        ),
      );
    }
    return repository.saveEvaluation(evaluation);
  }
}

class CalculateRankingsUseCase {
  const CalculateRankingsUseCase();
  Result<List<RankingEntry>> call(CampusData data, {String? evaluatorUid}) {
    final totals = <String, List<int>>{};
    for (final rating in data.evaluations) {
      if (rating.valid &&
          (evaluatorUid == null || rating.evaluatorUid == evaluatorUid)) {
        (totals[rating.personId] ??= []).add(rating.total);
      }
    }
    final entries = <RankingEntry>[];
    for (final person in data.people.where((p) => p.active)) {
      final values = totals[person.id];
      if (values != null && values.isNotEmpty) {
        entries.add(
          RankingEntry(
            person,
            values.reduce((a, b) => a + b) / values.length,
            values.length,
          ),
        );
      }
    }
    entries.sort((a, b) {
      final score = b.average.compareTo(a.average);
      if (score != 0) return score;
      final name = a.person.name.toLowerCase().compareTo(
        b.person.name.toLowerCase(),
      );
      return name != 0 ? name : a.person.id.compareTo(b.person.id);
    });
    return Success(entries);
  }
}
