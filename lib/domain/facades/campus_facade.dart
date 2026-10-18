import '../repositories/campus_repository.dart';
import '../usecases/campus_usecases.dart';

class CampusFacade {
  final String uid;
  final LoadCampusUseCase load;
  final SavePersonUseCase savePerson;
  final RemovePersonUseCase removePerson;
  final LinkPersonUseCase linkPerson;
  final SaveEvaluationUseCase evaluate;
  final ranking = const CalculateRankingsUseCase();
  CampusFacade(CampusRepository repo)
    : uid = repo.uid,
      load = LoadCampusUseCase(repo),
      savePerson = SavePersonUseCase(repo),
      removePerson = RemovePersonUseCase(repo),
      linkPerson = LinkPersonUseCase(repo),
      evaluate = SaveEvaluationUseCase(repo);
}
