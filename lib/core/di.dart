import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/campus_repository_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/theme_repository_impl.dart';
import '../data/services/auth_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/profile_service.dart';
import '../data/services/local_storage_service.dart';
import '../domain/facades/campus_facade.dart';
import '../domain/facades/auth_facade.dart';
import '../domain/facades/theme_facade.dart';
import '../domain/usecases/get_theme_usecase.dart';
import '../domain/usecases/save_theme_usecase.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/campus_viewmodel.dart';
import '../presentation/viewmodels/theme_viewmodel.dart';

late ThemeViewModel themeViewModel;
late AuthViewModel authViewModel;
late CampusViewModel campusViewModel;
Future<void> initDependencies() async {
  final themeRepo = ThemeRepositoryImpl(
    LocalStorageService(SharedPreferencesAsync()),
  );
  themeViewModel = ThemeViewModel(
    ThemeFacade(
      getThemeUseCase: GetThemeUseCase(themeRepo),
      saveThemeUseCase: SaveThemeUseCase(themeRepo),
    ),
  );
  await themeViewModel.loadThemeCommand.execute();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  authViewModel = AuthViewModel(
    AuthFacade(AuthRepositoryImpl(AuthService(auth), ProfileService(db, auth))),
    onSessionChanged: (uid) {
      campusViewModel = CampusViewModel(
        CampusFacade(
          CampusRepositoryImpl(FirestoreService(db, auth, uid ?? '')),
        ),
      );
    },
  );
}
