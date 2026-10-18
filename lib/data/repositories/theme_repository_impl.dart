import '../services/local_storage_service.dart';
import '../../core/result/result.dart';
import '../../domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final LocalStorageService preferences;
  ThemeRepositoryImpl(this.preferences);
  @override
  Future<Result<bool>> isDarkMode() async {
    try {
      return Success(await preferences.loadTheme());
    } catch (e) {
      return Failure(e, 'Falha ao recuperar o tema.');
    }
  }

  @override
  Future<Result<void>> setDarkMode(bool isDark) async {
    try {
      await preferences.saveTheme(isDark);
      return const Success(null);
    } catch (e) {
      return Failure(e, 'Falha ao salvar o tema.');
    }
  }
}
