import '../../core/result/result.dart';
import '../entities/student.dart';
import '../usecases/save_student_usecase.dart';
import '../usecases/delete_student_usecase.dart';
import '../usecases/get_students_usecase.dart';
import '../usecases/get_student_by_id_usecase.dart';
import '../usecases/calculate_ranking_usecase.dart';

class StudentFacade {
  final GetStudentsUseCase _getStudentsUseCase;
  final GetStudentByIdUseCase _getStudentByIdUseCase;
  final SaveStudentUseCase _saveStudentUseCase;
  final DeleteStudentUseCase _deleteStudentUseCase;
  final CalculateRankingUseCase _calculateRankingUseCase;

  const StudentFacade({
    required GetStudentsUseCase getStudentsUseCase,
    required GetStudentByIdUseCase getStudentByIdUseCase,
    required SaveStudentUseCase saveStudentUseCase,
    required DeleteStudentUseCase deleteStudentUseCase,
    required CalculateRankingUseCase calculateRankingUseCase,
  })  : _getStudentsUseCase = getStudentsUseCase,
        _getStudentByIdUseCase = getStudentByIdUseCase,
        _saveStudentUseCase = saveStudentUseCase,
        _deleteStudentUseCase = deleteStudentUseCase,
        _calculateRankingUseCase = calculateRankingUseCase;

  Future<Result<List<Student>>> getStudents() {
    return _getStudentsUseCase();
  }

  Future<Result<Student?>> getStudentById(String id) {
    return _getStudentByIdUseCase(id);
  }

  Future<Result<void>> saveStudent(Student student) {
    return _saveStudentUseCase(student);
  }

  Future<Result<void>> deleteStudent(String id) {
    return _deleteStudentUseCase(id);
  }

  Result<List<Student>> calculateRanking(List<Student> students) {
    return _calculateRankingUseCase(students);
  }
}
