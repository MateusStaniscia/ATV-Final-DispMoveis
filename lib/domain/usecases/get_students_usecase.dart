import '../../core/result/result.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class GetStudentsUseCase {
  final StudentRepository _repository;

  const GetStudentsUseCase(this._repository);

  Future<Result<List<Student>>> call() {
    return _repository.getStudents();
  }
}
