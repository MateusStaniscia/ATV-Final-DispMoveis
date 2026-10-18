import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result/result.dart';
import '../../domain/entities/campus.dart';
import '../../domain/repositories/campus_repository.dart';
import '../services/firestore_service.dart';

class CampusRepositoryImpl implements CampusRepository {
  final FirestoreService service;
  CampusRepositoryImpl(this.service);
  @override
  String get uid => service.uid;
  Future<Result<T>> _guard<T>(Future<T> Function() work) async {
    try {
      return Success(await work());
    } catch (e) {
      return Failure(
        e,
        e is StateError
            ? e.message.toString()
            : e is FirebaseException && e.code == 'permission-denied'
            ? 'Operação não permitida. Confira sua sessão e as permissões deste registro.'
            : 'Falha ao acessar a nuvem. Confira a conexão e tente novamente.',
      );
    }
  }

  @override
  Future<Result<CampusData>> load() => _guard(() async {
    final data = await service.load();
    final people = (data['people'] as List)
        .map(
          (d) => Person(
            id: d['id'],
            name: d['name'],
            nickname: d['nickname'],
            course: d['course'],
            year: d['year'],
            birthDate: (d['birthDate'] as Timestamp).toDate(),
            createdBy: d['createdBy'],
            linkedUid: d['linkedUid'],
            active: d['active'],
          ),
        )
        .toList();
    people.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final ratings = (data['ratings'] as List)
        .map(
          (d) => Evaluation(
            evaluatorUid: d['evaluatorUid'],
            personId: d['personId'],
            scores: Map<String, int>.from(d['scores']),
            date: (d['date'] as Timestamp).toDate(),
          ),
        )
        .toList();
    return CampusData(people, ratings, data['personId']);
  });
  @override
  Future<Result<void>> savePerson(Person p) => _guard(
    () => service.savePerson(p.id, {
      'name': p.name,
      'nickname': p.nickname,
      'course': p.course,
      'year': p.year,
      'birthDate': Timestamp.fromDate(p.birthDate),
    }),
  );
  @override
  Future<Result<void>> removePerson(String id) =>
      _guard(() => service.removePerson(id));
  @override
  Future<Result<void>> linkPerson(String id) =>
      _guard(() => service.linkPerson(id));
  @override
  Future<Result<void>> saveEvaluation(Evaluation e) => _guard(
    () => service.saveEvaluation(e.personId, {
      'scores': e.scores,
      'total': e.total,
    }),
  );
}
