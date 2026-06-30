import 'package:go_router/go_router.dart';
import '../../presentation/ui/about/about_screen.dart';
import '../../presentation/ui/details/student_detail_screen.dart';
import '../../presentation/ui/form/student_form_screen.dart';
import '../../presentation/ui/home/home_screen.dart';
import '../../presentation/ui/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/form',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        return StudentFormScreen(studentId: id);
      },
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return StudentDetailScreen(studentId: id);
      },
    ),
  ],
);
