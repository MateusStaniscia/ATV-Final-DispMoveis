import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command/command.dart';
import '../../core/result/result.dart';
import '../../domain/entities/campus.dart';
import '../../domain/facades/campus_facade.dart';

class EvaluationRequest {
  final Person person;
  final Map<String, int> scores;
  EvaluationRequest(this.person, this.scores);
}

class CampusViewModel {
  final CampusFacade facade;
  String get uid => facade.uid;
  final data = signal(const CampusData([], [], null));
  final error = signal('');
  final loaded = signal(false);
  late final Computed<List<RankingEntry>> personalRanking, globalRanking;
  late final Command<CampusData> loadCommand;
  late final CommandWithParam<void, Person> savePersonCommand;
  late final CommandWithParam<void, String> removePersonCommand,
      linkPersonCommand;
  late final CommandWithParam<void, EvaluationRequest> evaluateCommand;
  CampusViewModel(this.facade) {
    personalRanking = computed(
      () => facade.ranking(data.value, evaluatorUid: uid).getOrThrow(),
    );
    globalRanking = computed(() => facade.ranking(data.value).getOrThrow());
    loadCommand = Command(() async {
      error.value = '';
      final result = await facade.load();
      result.when(
        onSuccess: (value) {
          data.value = value;
          loaded.value = true;
        },
        onFailure: (e, msg) {
          data.value = const CampusData([], [], null);
          loaded.value = false;
          error.value = msg;
        },
      );
      return result;
    });
    savePersonCommand = CommandWithParam(
      (p) => _mutate(() => facade.savePerson(p)),
    );
    removePersonCommand = CommandWithParam(
      (id) => _mutate(() => facade.removePerson(id)),
    );
    linkPersonCommand = CommandWithParam(
      (id) => _mutate(() => facade.linkPerson(id)),
    );
    evaluateCommand = CommandWithParam(
      (r) => _mutate(
        () => facade.evaluate(
          Evaluation(
            evaluatorUid: uid,
            personId: r.person.id,
            scores: r.scores,
            date: DateTime.now(),
          ),
          r.person,
        ),
      ),
    );
  }
  Future<Result<void>> _mutate(Future<Result<void>> Function() action) async {
    error.value = '';
    final result = await action();
    if (result is Failure<void>) {
      error.value = result.message;
    } else {
      await loadCommand.execute();
    }
    return result;
  }

  Person? person(String id) {
    for (final p in data.value.people) {
      if (p.id == id) return p;
    }
    return null;
  }

  Evaluation? myEvaluation(String id) {
    for (final e in data.value.evaluations) {
      if (e.personId == id && e.evaluatorUid == uid) return e;
    }
    return null;
  }

  bool canEdit(Person p) => p.createdBy == uid || p.linkedUid == uid;
  bool canRemove(Person p) => p.createdBy == uid && p.linkedUid == null;
  bool canEvaluate(Person p) =>
      p.active && p.linkedUid != uid && data.value.myPersonId != p.id;
}
