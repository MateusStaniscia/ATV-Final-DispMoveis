import '../../core/result/result.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class GetStudentByIdUseCase {
  final StudentRepository _repository;

  const GetStudentByIdUseCase(this._repository);

  Future<Result<Student?>> call(String id) {
    return _repository.getStudentById(id);
  }
}
