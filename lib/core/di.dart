import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/student_repository_impl.dart';
import '../data/repositories/theme_repository_impl.dart';
import '../data/services/auth_service.dart';
import '../domain/facades/student_facade.dart';
import '../domain/facades/theme_facade.dart';
import '../domain/usecases/calculate_ranking_usecase.dart';
import '../domain/usecases/delete_student_usecase.dart';
import '../domain/usecases/get_student_by_id_usecase.dart';
import '../domain/usecases/get_students_usecase.dart';
import '../domain/usecases/get_theme_usecase.dart';
import '../domain/usecases/save_student_usecase.dart';
import '../domain/usecases/save_theme_usecase.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/student_detail_viewmodel.dart';
import '../presentation/viewmodels/student_form_viewmodel.dart';
import '../presentation/viewmodels/student_list_viewmodel.dart';
import '../presentation/viewmodels/theme_viewmodel.dart';

late ThemeViewModel themeViewModel;
late AuthViewModel authViewModel;
late StudentListViewModel studentListViewModel;
late StudentFormViewModel studentFormViewModel;
late StudentDetailViewModel studentDetailViewModel;

Future<void> initDependencies() async {
  final themeRepo = ThemeRepositoryImpl(SharedPreferencesAsync());
  themeViewModel = ThemeViewModel(
    ThemeFacade(
      getThemeUseCase: GetThemeUseCase(themeRepo),
      saveThemeUseCase: SaveThemeUseCase(themeRepo),
    ),
  );
  await themeViewModel.loadThemeCommand.execute();
  authViewModel = AuthViewModel(
    AuthService(FirebaseAuth.instance),
    onSessionChanged: _createSessionDependencies,
  );
}

/// Descarta referências ao estado da conta anterior antes de liberar as rotas.
void _createSessionDependencies(String? uid) {
  final repo = StudentRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    uid,
  );
  final facade = StudentFacade(
    getStudentsUseCase: GetStudentsUseCase(repo),
    getStudentByIdUseCase: GetStudentByIdUseCase(repo),
    saveStudentUseCase: SaveStudentUseCase(repo),
    deleteStudentUseCase: DeleteStudentUseCase(repo),
    calculateRankingUseCase: const CalculateRankingUseCase(),
  );
  studentListViewModel = StudentListViewModel(facade);
  studentFormViewModel = StudentFormViewModel(facade);
  studentDetailViewModel = StudentDetailViewModel(facade);
}
