import '../../core/result/result.dart';
import '../../domain/repositories/theme_repository.dart';
import '../services/shared_preferences_service.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final SharedPreferencesService _service;
  static const String _themeKey = 'is_dark_mode';

  const ThemeRepositoryImpl(this._service);

  @override
  Future<Result<bool>> isDarkMode() async {
    try {
      final isDark = await _service.getBool(_themeKey);
      return Success(isDark);
    } catch (e) {
      return Failure(e, 'Falha ao recuperar preferência de tema.');
    }
  }

  @override
  Future<Result<void>> setDarkMode(bool isDark) async {
    try {
      final success = await _service.setBool(_themeKey, isDark);
      if (success) {
        return const Success(null);
      }
      return Failure(StateError('Falha ao gravar preferência de tema.'));
    } catch (e) {
      return Failure(e, 'Falha ao salvar preferência de tema.');
    }
  }
}
