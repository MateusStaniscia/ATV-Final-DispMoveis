import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Único ponto de acesso ao Firestore. Cada instância pertence a um UID.
class FirestoreService {
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  final String uid;
  FirestoreService(this.db, this.auth, this.uid);
  void checkSession() {
    if (uid.isEmpty || auth.currentUser?.uid != uid) {
      throw StateError('Sua sessão terminou. Entre novamente.');
    }
  }

  Future<Map<String, dynamic>> load() async {
    checkSession();
    final people = await db
        .collection('people')
        .where('active', isEqualTo: true)
        .get(const GetOptions(source: Source.server));
    final ratings = await db
        .collectionGroup('ratings')
        .get(const GetOptions(source: Source.server));
    final profile = await db
        .collection('users')
        .doc(uid)
        .get(const GetOptions(source: Source.server));
    checkSession();
    return {
      'people': people.docs.map((d) => {...d.data(), 'id': d.id}).toList(),
      'ratings': ratings.docs.map((d) => d.data()).toList(),
      'personId': profile.data()?['personId'],
    };
  }

  Future<void> savePerson(String id, Map<String, dynamic> data) async {
    checkSession();
    final ref = id.isEmpty
        ? db.collection('people').doc()
        : db.collection('people').doc(id);
    await db.runTransaction((tx) async {
      checkSession();
      final current = await tx.get(ref);
      if (id.isNotEmpty && !current.exists) {
        throw StateError('Pessoa não encontrada.');
      }
      if (current.exists) {
        tx.update(ref, data);
      } else {
        tx.set(ref, {
          ...data,
          'createdBy': uid,
          'linkedUid': null,
          'active': true,
        });
      }
    });
    checkSession();
  }

  Future<void> removePerson(String id) async {
    checkSession();
    await db.runTransaction((tx) async {
      checkSession();
      tx.update(db.collection('people').doc(id), {'active': false});
    });
    checkSession();
  }

  Future<void> linkPerson(String id) async {
    checkSession();
    final person = db.collection('people').doc(id);
    final profile = db.collection('users').doc(uid);
    await db.runTransaction((tx) async {
      checkSession();
      final p = await tx.get(person);
      final u = await tx.get(profile);
      if (!p.exists ||
          p.data()?['active'] != true ||
          p.data()?['linkedUid'] != null ||
          u.data()?['personId'] != null) {
        throw StateError(
          'Este vínculo não está disponível. Cada conta pode ter apenas uma pessoa vinculada.',
        );
      }
      tx.update(person, {'linkedUid': uid});
      tx.update(profile, {'personId': id});
      // Um vínculo tardio não deixa uma autoavaliação já existente no ranking.
      tx.delete(person.collection('ratings').doc(uid));
    });
    checkSession();
  }

  Future<void> saveEvaluation(
    String personId,
    Map<String, dynamic> data,
  ) async {
    checkSession();
    final person = db.collection('people').doc(personId);
    await db.runTransaction((tx) async {
      checkSession();
      final p = await tx.get(person);
      if (!p.exists || p.data()?['active'] != true) {
        throw StateError('Pessoa indisponível. Atualize a lista.');
      }
      if (p.data()?['linkedUid'] == uid) {
        throw StateError('Você não pode avaliar a si próprio.');
      }
      tx.set(person.collection('ratings').doc(uid), {
        ...data,
        'evaluatorUid': uid,
        'personId': personId,
        'date': FieldValue.serverTimestamp(),
      });
    });
    checkSession();
  }
}
