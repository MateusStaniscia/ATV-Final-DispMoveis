import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'core/di.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa a injeção de dependências e preferências locais
  await initDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Assina reativamente o sinal de tema escuro para reconstruir o MaterialApp
    final isDarkMode = themeViewModel.isDarkMode.watch(context);

    return MaterialApp.router(
      title: 'PirâmidGame IFPR-Pgua',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
