import '../../core/result/result.dart';
import '../entities/campus.dart';

abstract interface class CampusRepository {
  String get uid;
  Future<Result<CampusData>> load();
  Future<Result<void>> savePerson(Person person);
  Future<Result<void>> removePerson(String id);
  Future<Result<void>> linkPerson(String id);
  Future<Result<void>> saveEvaluation(Evaluation evaluation);
}
