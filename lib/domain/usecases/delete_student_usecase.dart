import '../../core/result/result.dart';
import '../repositories/student_repository.dart';

class DeleteStudentUseCase {
  final StudentRepository _repository;

  const DeleteStudentUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteStudent(id);
  }
}
