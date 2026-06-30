import '../../core/result/result.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class SaveStudentUseCase {
  final StudentRepository _repository;

  const SaveStudentUseCase(this._repository);

  Future<Result<void>> call(Student student) async {
    // Validações de Regra de Negócio
    if (student.name.trim().isEmpty) {
      return Failure(
        ArgumentError('O nome do aluno é obrigatório.'),
        'O nome do aluno é obrigatório.',
      );
    }
    
    const validCourses = ['INFO', 'MEC', 'MAMB', 'PROD', 'TADS', 'TGA'];
    if (!validCourses.contains(student.course)) {
      return Failure(
        ArgumentError('Curso inválido.'),
        'O curso selecionado é inválido.',
      );
    }

    if (student.year < 1998 || student.year > 2026) {
      return Failure(
        ArgumentError('Ano inválido.'),
        'A turma/ano deve ser escolhida entre 1998 e 2026.',
      );
    }

    for (final score in student.scores.values) {
      if (score < 1 || score > 5) {
        return Failure(
          ArgumentError('Nota fora do intervalo.'),
          'Cada critério deve possuir nota entre 1 e 5 estrelas.',
        );
      }
    }

    return _repository.saveStudent(student);
  }
}
