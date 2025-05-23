import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

FirebaseFirestore _fs([FirebaseFirestore? f]) =>
    f ?? FirebaseFirestore.instance;
FirebaseAuth _auth([FirebaseAuth? a]) => a ?? FirebaseAuth.instance;

/// Colección `.../users/{uid}/pets`
CollectionReference<Map<String, dynamic>> _petsCol(
  FirebaseFirestore firestore,
  String uid,
) => firestore.collection('users').doc(uid).collection('pets');

Future<String> addPet(
  Map<String, dynamic> petData, {
  FirebaseFirestore? firestore,
  FirebaseAuth? auth,
}) async {
  final fs = _fs(firestore);
  final user = _auth(auth).currentUser;
  if (user == null) throw StateError('No authenticated user');

  final petId = _uuid.v4();
  final now = FieldValue.serverTimestamp();

  await _petsCol(fs, user.uid).doc(petId).set({
    ...petData,
    'petId': petId,
    'createdAt': now,
    'updatedAt': now,
  });

  return petId;
}

Future<void> updatePet(
  String petId,
  Map<String, dynamic> data, {
  FirebaseFirestore? firestore,
  FirebaseAuth? auth,
}) async {
  final fs = _fs(firestore);
  final user = _auth(auth).currentUser;
  if (user == null) throw StateError('No authenticated user');

  await _petsCol(
    fs,
    user.uid,
  ).doc(petId).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
}

Future<List<Map<String, dynamic>>> getPets({
  FirebaseFirestore? firestore,
  FirebaseAuth? auth,
}) async {
  final fs = _fs(firestore);
  final user = _auth(auth).currentUser;
  if (user == null) throw StateError('No authenticated user');

  final snap = await _petsCol(fs, user.uid).orderBy('name').get();

  return snap.docs
      .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
      .toList();
}

Future<Map<String, dynamic>> getPetById(
  String petId, {
  FirebaseFirestore? firestore,
  FirebaseAuth? auth,
}) async {
  final fs = _fs(firestore);
  final user = _auth(auth).currentUser;
  if (user == null) throw StateError('No authenticated user');

  final doc = await _petsCol(fs, user.uid).doc(petId).get();
  if (!doc.exists) throw StateError('Pet not found');
  return <String, dynamic>{'id': doc.id, ...doc.data()!};
}

Future<void> deletePet(
  String petId, {
  FirebaseFirestore? firestore,
  FirebaseAuth? auth,
}) async {
  final fs = _fs(firestore);
  final user = _auth(auth).currentUser;
  if (user == null) throw StateError('No authenticated user');
  await _petsCol(fs, user.uid).doc(petId).delete();
}
