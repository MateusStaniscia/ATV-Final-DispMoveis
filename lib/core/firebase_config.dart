import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class FirebaseConfig {
  static const useEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );

  static Future<void> initialize() async {
    if (!useEmulators &&
        [projectId, apiKey, appId, senderId].any((value) => value.isEmpty)) {
      throw StateError(
        'Configure o Firebase conforme o README ou inicie com '
        '--dart-define=USE_FIREBASE_EMULATORS=true.',
      );
    }
    if (useEmulators && kReleaseMode) {
      throw StateError('Emuladores não são permitidos em builds de produção.');
    }
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: useEmulators ? 'demo-api-key' : apiKey,
        appId: useEmulators ? '1:123456789:web:demo' : appId,
        messagingSenderId: useEmulators ? '123456789' : senderId,
        projectId: useEmulators ? 'demo-piramid-game' : projectId,
        authDomain: useEmulators ? null : '$projectId.firebaseapp.com',
      ),
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
    if (useEmulators) {
      const configuredHost = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
      final host = configuredHost.isNotEmpty
          ? configuredHost
          : (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
                ? '10.0.2.2'
                : '127.0.0.1');
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    }
  }
}
