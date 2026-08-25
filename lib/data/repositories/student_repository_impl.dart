import 'package:sqflite/sqflite.dart';
import '../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/student_model.dart';
import '../services/sqlite_service.dart';

class StudentRepositoryImpl implements StudentRepository {
  final DatabaseHelper _dbHelper;

  const StudentRepositoryImpl(this._dbHelper);

  @override
  Future<Result<List<Student>>> getStudents() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('students');
      
      final List<Student> students = maps.map((map) => StudentModel.fromMap(map)).toList();
      return Success(students);
    } catch (e) {
      return Failure(e, 'Falha ao recuperar a lista de alunos.');
    }
  }

  @override
  Future<Result<Student?>> getStudentById(String id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Success(StudentModel.fromMap(maps.first));
      }
      return const Success(null);
    } catch (e) {
      return Failure(e, 'Falha ao buscar aluno pelo identificador.');
    }
  }

  @override
  Future<Result<void>> saveStudent(Student student) async {
    try {
      final db = await _dbHelper.database;
      final model = StudentModel.fromEntity(student);
      
      await db.insert(
        'students',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Success(null);
    } catch (e) {
      return Failure(e, 'Falha ao salvar aluno.');
    }
  }

  @override
  Future<Result<void>> deleteStudent(String id) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count > 0) {
        return const Success(null);
      } else {
        return Failure(ArgumentError('Aluno não encontrado para exclusão.'));
      }
    } catch (e) {
      return Failure(e, 'Falha ao excluir aluno.');
    }
  }
}
