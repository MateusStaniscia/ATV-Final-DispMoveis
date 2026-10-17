import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'core/di.dart';
import 'core/firebase_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseConfig.initialize();
    await initDependencies();
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Configuração do Firebase')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'Não foi possível iniciar o aplicativo.\n\n$e\n\n'
              'Consulte as instruções de configuração no README.',
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends SignalStatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = createAppRouter(authViewModel);
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeViewModel.isDarkMode.value;
    return MaterialApp.router(
      title: 'PirâmidGame IFPR-Pgua',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      builder: (context, child) => FirebaseConfig.useEmulators
          ? Banner(
              message: 'EMULADOR',
              location: BannerLocation.topEnd,
              child: child!,
            )
          : child!,
    );
  }
}
