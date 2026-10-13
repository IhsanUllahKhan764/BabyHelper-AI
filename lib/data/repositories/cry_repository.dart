import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baby_helper_ai/data/models/cry_result_model.dart';

class CryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CryRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference _cryCol(String babyId) => _firestore
      .collection('users')
      .doc(_uid)
      .collection('babies')
      .doc(babyId)
      .collection('cryResults');

  Future<CryResultModel> saveResult(String babyId, CryResultModel result) async {
    final doc = await _cryCol(babyId).add(result.toMap());
    return CryResultModel(
      id: doc.id,
      category: result.category,
      confidence: result.confidence,
      timestamp: result.timestamp,
      allProbabilities: result.allProbabilities,
    );
  }

  Future<List<CryResultModel>> getResults(String babyId, {int limit = 20}) async {
    final snapshot = await _cryCol(babyId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      return CryResultModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<List<CryResultModel>> getRecentResults(String babyId, {int limit = 5}) async {
    return getResults(babyId, limit: limit);
  }

  Future<void> deleteResult(String babyId, String resultId) async {
    await _cryCol(babyId).doc(resultId).delete();
  }
}
