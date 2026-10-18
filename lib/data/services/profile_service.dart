import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  ProfileService(this.db, this.auth);
  Future<void> sync(User user) async {
    final ref = db.collection('users').doc(user.uid);
    await db.runTransaction((tx) async {
      if (auth.currentUser?.uid != user.uid) {
        throw StateError('Sessão alterada.');
      }
      final current = await tx.get(ref);
      final data = {
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photo': user.photoURL ?? '',
        'provider': user.providerData.map((p) => p.providerId).join(','),
      };
      if (current.exists) {
        tx.update(ref, data);
      } else {
        tx.set(ref, {...data, 'personId': null});
      }
    });
  }
}
