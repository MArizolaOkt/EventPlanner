import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Firestore collection untuk event
  final CollectionReference events = FirebaseFirestore.instance.collection(
    'events',
  );

  // CREATE: tambah event
  Future<void> addEvent(Map<String, dynamic> eventData) {
    return events.add({...eventData, 'timestamp': Timestamp.now()});
  }

  // READ: ambil stream event berdasarkan ownerId
  Stream<QuerySnapshot> getEventsStream(String uid) {
    return events
        .where('ownerId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // UPDATE: edit event berdasarkan docID
  Future<void> updateEvent(String docID, Map<String, dynamic> updatedData) {
    return events.doc(docID).update({
      ...updatedData,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE: hapus event berdasarkan docID
  Future<void> deleteEvent(String docID) {
    return events.doc(docID).delete();
  }
}
