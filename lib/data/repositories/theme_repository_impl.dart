import 'package:sqflite/sqflite.dart';
import '../../core/result/result.dart';
import '../../domain/repositories/theme_repository.dart';
import '../services/sqlite_service.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final DatabaseHelper _dbHelper;
  static const String _themeKey = 'is_dark_mode';

  const ThemeRepositoryImpl(this._dbHelper);

  @override
  Future<Result<bool>> isDarkMode() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'preferences',
        where: 'key = ?',
        whereArgs: [_themeKey],
      );

      if (maps.isNotEmpty) {
        final isDarkStr = maps.first['value'] as String;
        return Success(isDarkStr == 'true');
      }
      return const Success(false); // Default é false
    } catch (e) {
      return Failure(e, 'Falha ao recuperar preferência de tema.');
    }
  }

  @override
  Future<Result<void>> setDarkMode(bool isDark) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'preferences',
        {'key': _themeKey, 'value': isDark.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Success(null);
    } catch (e) {
      return Failure(e, 'Falha ao salvar preferência de tema.');
    }
  }
}
