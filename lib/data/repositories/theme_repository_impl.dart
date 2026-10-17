import 'package:shared_preferences/shared_preferences.dart';
import '../../core/result/result.dart';
import '../../domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final SharedPreferencesAsync preferences;
  ThemeRepositoryImpl(this.preferences);
  @override
  Future<Result<bool>> isDarkMode() async {
    try {
      return Success(await preferences.getBool('is_dark_mode') ?? false);
    } catch (e) {
      return Failure(e, 'Falha ao recuperar o tema.');
    }
  }

  @override
  Future<Result<void>> setDarkMode(bool isDark) async {
    try {
      await preferences.setBool('is_dark_mode', isDark);
      return const Success(null);
    } catch (e) {
      return Failure(e, 'Falha ao salvar o tema.');
    }
  }
}
