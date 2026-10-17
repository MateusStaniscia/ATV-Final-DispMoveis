/// Política única aplicada também a URLs abertas diretamente.
String? sessionRedirect({
  required bool ready,
  required bool signedIn,
  required String location,
}) {
  if (!ready) return location == '/' ? null : '/';
  if (!signedIn) return location == '/login' ? null : '/login';
  if (location == '/' || location == '/login') return '/home';
  return null;
}
