import '../../data/repositories/student_repository_impl.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../data/services/sqlite_service.dart';
import '../../domain/facades/student_facade.dart';
import '../../domain/facades/theme_facade.dart';
import '../../domain/usecases/calculate_ranking_usecase.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import '../../domain/usecases/get_student_by_id_usecase.dart';
import '../../domain/usecases/get_students_usecase.dart';
import '../../domain/usecases/get_theme_usecase.dart';
import '../../domain/usecases/save_student_usecase.dart';
import '../../domain/usecases/save_theme_usecase.dart';
import '../../presentation/viewmodels/student_detail_viewmodel.dart';
import '../../presentation/viewmodels/student_form_viewmodel.dart';
import '../../presentation/viewmodels/student_list_viewmodel.dart';
import '../../presentation/viewmodels/theme_viewmodel.dart';

late final ThemeViewModel themeViewModel;
late final StudentListViewModel studentListViewModel;
late final StudentFormViewModel studentFormViewModel;
late final StudentDetailViewModel studentDetailViewModel;

/// Inicializa todas as dependências do projeto seguindo estritamente a hierarquia:
/// Services -> Repositories -> Use Cases -> Facade de Use Cases -> ViewModel
Future<void> initDependencies() async {
  // 1. Instanciação do Service (Acesso ao SQLite)
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  // 2. Instanciação dos Repositories
  final studentRepo = StudentRepositoryImpl(dbHelper);
  final themeRepo = ThemeRepositoryImpl(dbHelper);

  // 3. Instanciação dos Use Cases (Regras de Negócio Isoladas)
  final getStudents = GetStudentsUseCase(studentRepo);
  final getStudentById = GetStudentByIdUseCase(studentRepo);
  final saveStudent = SaveStudentUseCase(studentRepo);
  final deleteStudent = DeleteStudentUseCase(studentRepo);
  final calculateRanking = const CalculateRankingUseCase();

  final getTheme = GetThemeUseCase(themeRepo);
  final saveTheme = SaveThemeUseCase(themeRepo);

  // 4. Instanciação das Facades de Use Cases
  final studentFacade = StudentFacade(
    getStudentsUseCase: getStudents,
    getStudentByIdUseCase: getStudentById,
    saveStudentUseCase: saveStudent,
    deleteStudentUseCase: deleteStudent,
    calculateRankingUseCase: calculateRanking,
  );

  final themeFacade = ThemeFacade(
    getThemeUseCase: getTheme,
    saveThemeUseCase: saveTheme,
  );

  // 5. Instanciação das ViewModels injetando apenas as Facades correspondentes
  themeViewModel = ThemeViewModel(themeFacade);
  studentListViewModel = StudentListViewModel(studentFacade);
  studentFormViewModel = StudentFormViewModel(studentFacade);
  studentDetailViewModel = StudentDetailViewModel(studentFacade);

  // Carrega a preferência de tema gravada
  await themeViewModel.loadThemeCommand.execute();
}
