import '../../presentation/ui/evaluation/evaluation_screen.dart';
import '../../presentation/ui/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'session_redirect.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/ui/auth/login_screen.dart';
import '../../presentation/ui/about/about_screen.dart';
import '../../presentation/ui/details/student_detail_screen.dart';
import '../../presentation/ui/form/student_form_screen.dart';
import '../../presentation/ui/home/home_screen.dart';

GoRouter createAppRouter(AuthViewModel session) => GoRouter(
  initialLocation: '/',
  refreshListenable: session,
  redirect: (context, state) => sessionRedirect(
    ready: session.ready,
    signedIn: session.user != null,
    location: state.uri.path,
  ),
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(model: session),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/evaluate/:id',
      builder: (context, state) =>
          EvaluationScreen(personId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/form',
      builder: (context, state) =>
          StudentFormScreen(studentId: state.uri.queryParameters['id']),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) =>
          StudentDetailScreen(studentId: state.pathParameters['id']!),
    ),
  ],
);
