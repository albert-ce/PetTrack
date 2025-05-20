import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

/// Adds a new pet for the currently‑signed‑in user and returns the generated
/// `petId`.
///
/// The pet document is stored at the path:
/// `/users/{uid}/pets/{petId}`
///
/// Pass the pet's fields in [petData] (name, species, birthDate, ...). Optional
/// [firestore] and [auth] params allow dependency injection in tests.
Future<String> addPet(
  Map<String, dynamic> petData, {
  FirebaseFirestore? firestore,
  FirebaseAuth? auth,
}) async {
  final _firestore = firestore ?? FirebaseFirestore.instance;
  final _auth = auth ?? FirebaseAuth.instance;

  final user = _auth.currentUser;
  if (user == null) {
    throw StateError('No authenticated user');
  }

  // Generate a UUID v4 so we can reference the same ID from Cloud Functions.
  const uuid = Uuid();
  final petId = uuid.v4();

  final now = FieldValue.serverTimestamp();
  await _firestore
      .collection('users')
      .doc(user.uid)
      .collection('pets')
      .doc(petId)
      .set(<String, dynamic>{
        ...petData,
        'petId': petId,
        'createdAt': now,
        'updatedAt': now,
      });

  return petId;
}

Future<List<Map<String, dynamic>>> getPets({
  FirebaseFirestore? firestore,
  FirebaseAuth? auth,
}) async {
  final _firestore = firestore ?? FirebaseFirestore.instance;
  final _auth = auth ?? FirebaseAuth.instance;
  final user = _auth.currentUser;
  if (user == null) {
    throw StateError('No authenticated user');
  }

  final snap =
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .orderBy('name')
          .get();

  return snap.docs
      .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
      .toList();
}

                        // try {
                        //   final pets = await getPets(); // ⇦ invoca la función
                        //   for (final pet in pets) {
                        //     debugPrint(
                        //       'Mascota: ${pet['name']} – id: ${pet['id']}',
                        //     );
                        //   }
                        // } catch (e) {
                        //   debugPrint('Error al leer mascotas: $e');
                        // }