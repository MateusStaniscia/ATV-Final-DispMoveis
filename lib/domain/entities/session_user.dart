class SessionUser {
  final String uid, email, name, photo, provider;
  const SessionUser({
    required this.uid,
    this.email = '',
    this.name = '',
    this.photo = '',
    this.provider = 'password',
  });
}

class Credentials {
  final String email, password;
  const Credentials(this.email, this.password);
}
