import 'popularity_criteria.dart';

class Student {
  final String id;
  final String name;
  final String course;
  final int year;
  final String nickname;
  final DateTime birthDate;
  final Map<String, int> scores;

  const Student({
    required this.id,
    required this.name,
    required this.course,
    required this.year,
    required this.nickname,
    required this.birthDate,
    required this.scores,
  });

  /// Retorna o "Nível Lenda" calculando a soma de todos os 15 critérios.
  int get legendLevel {
    int total = 0;
    for (final criteria in PopularityCriteria.values) {
      final score = scores[criteria.id] ?? 1; // Default a 1 estrela caso não preenchido
      total += score.clamp(1, 5);
    }
    return total;
  }

  /// Retorna uma nova instância com campos modificados.
  Student copyWith({
    String? id,
    String? name,
    String? course,
    int? year,
    String? nickname,
    DateTime? birthDate,
    Map<String, int>? scores,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      course: course ?? this.course,
      year: year ?? this.year,
      nickname: nickname ?? this.nickname,
      birthDate: birthDate ?? this.birthDate,
      scores: scores ?? Map.from(this.scores),
    );
  }
}
