import '../../domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.course,
    required super.year,
    required super.nickname,
    required super.birthDate,
    required super.scores,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final Map<String, int> parsedScores = {};
    if (json['scores'] != null) {
      (json['scores'] as Map<String, dynamic>).forEach((key, value) {
        parsedScores[key] = (value as num).toInt();
      });
    }
    
    return StudentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      course: json['course'] as String,
      year: (json['year'] as num).toInt(),
      nickname: json['nickname'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      scores: parsedScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'course': course,
      'year': year,
      'nickname': nickname,
      'birthDate': birthDate.toIso8601String(),
      'scores': scores,
    };
  }

  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      name: student.name,
      course: student.course,
      year: student.year,
      nickname: student.nickname,
      birthDate: student.birthDate,
      scores: student.scores,
    );
  }
}
