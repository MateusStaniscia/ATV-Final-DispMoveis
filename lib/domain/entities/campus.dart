import 'popularity_criteria.dart';

class Person {
  final String id, name, nickname, course, createdBy;
  final int year;
  final DateTime birthDate;
  final String? linkedUid;
  final bool active;
  const Person({
    required this.id,
    required this.name,
    required this.nickname,
    required this.course,
    required this.year,
    required this.birthDate,
    required this.createdBy,
    this.linkedUid,
    this.active = true,
  });
}

class Evaluation {
  final String evaluatorUid, personId;
  final Map<String, int> scores;
  final DateTime date;
  Evaluation({
    required this.evaluatorUid,
    required this.personId,
    required Map<String, int> scores,
    required this.date,
  }) : scores = Map.unmodifiable(scores);
  int get total => scores.values.fold(0, (sum, score) => sum + score);
  bool get valid =>
      scores.length == PopularityCriteria.values.length &&
      PopularityCriteria.values.every(
        (c) => scores[c.id] != null && scores[c.id]! >= 1 && scores[c.id]! <= 5,
      );
}

class RankingEntry {
  final Person person;
  final double average;
  final int count;
  const RankingEntry(this.person, this.average, this.count);
}

class CampusData {
  final List<Person> people;
  final List<Evaluation> evaluations;
  final String? myPersonId;
  const CampusData(this.people, this.evaluations, this.myPersonId);
}
