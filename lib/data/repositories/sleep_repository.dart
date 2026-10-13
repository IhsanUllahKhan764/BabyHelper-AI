import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baby_helper_ai/data/models/sleep_session_model.dart';

class SleepRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SleepRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference _sleepCol(String babyId) => _firestore
      .collection('users')
      .doc(_uid)
      .collection('babies')
      .doc(babyId)
      .collection('sleepSessions');

  Future<SleepSessionModel> addSession(String babyId, SleepSessionModel session) async {
    final doc = await _sleepCol(babyId).add(session.toMap());
    return SleepSessionModel(
      id: doc.id,
      startTime: session.startTime,
      endTime: session.endTime,
      quality: session.quality,
      notes: session.notes,
    );
  }

  Future<List<SleepSessionModel>> getSessions(String babyId, {int limit = 50}) async {
    final snapshot = await _sleepCol(babyId)
        .orderBy('startTime', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      return SleepSessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<List<SleepSessionModel>> getTodaySessions(String babyId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot = await _sleepCol(babyId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return SleepSessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<List<SleepSessionModel>> getWeekSessions(String babyId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final snapshot = await _sleepCol(babyId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return SleepSessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> deleteSession(String babyId, String sessionId) async {
    await _sleepCol(babyId).doc(sessionId).delete();
  }
}
