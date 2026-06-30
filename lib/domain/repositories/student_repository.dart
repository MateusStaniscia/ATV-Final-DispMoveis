import '../../core/result/result.dart';
import '../entities/student.dart';

abstract class StudentRepository {
  Future<Result<List<Student>>> getStudents();
  Future<Result<Student?>> getStudentById(String id);
  Future<Result<void>> saveStudent(Student student);
  Future<Result<void>> deleteStudent(String id);
}
