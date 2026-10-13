import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_helper_ai/data/models/baby_model.dart';

class BabyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const _activeBabyKey = 'active_baby_id';

  BabyRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;
  CollectionReference get _babiesCol =>
      _firestore.collection('users').doc(_uid).collection('babies');

  Future<BabyModel> createBaby(BabyModel baby) async {
    final doc = await _babiesCol.add(baby.toMap());
    final created = baby.copyWith(id: doc.id);
    // Auto-set as active baby
    await setActiveBaby(doc.id);
    return created;
  }

  Future<List<BabyModel>> getBabies() async {
    final snapshot = await _babiesCol.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      return BabyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<BabyModel?> getActiveBaby() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString(_activeBabyKey);
    if (activeId != null) {
      try {
        final doc = await _babiesCol.doc(activeId).get();
        if (doc.exists) {
          return BabyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
      } catch (_) {}
    }
    // Fallback: return first baby
    return getFirstBaby();
  }

  Future<BabyModel?> getFirstBaby() async {
    final babies = await getBabies();
    if (babies.isNotEmpty) {
      await setActiveBaby(babies.first.id);
      return babies.first;
    }
    return null;
  }

  Future<void> setActiveBaby(String babyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeBabyKey, babyId);
  }

  Future<void> updateBaby(BabyModel baby) async {
    await _babiesCol.doc(baby.id).update(baby.toMap());
  }

  Future<void> deleteBaby(String babyId) async {
    // Delete all subcollections first
    await _deleteSubcollection(babyId, 'cry_results');
    await _deleteSubcollection(babyId, 'growth_measurements');
    await _deleteSubcollection(babyId, 'sleep_sessions');
    await _deleteSubcollection(babyId, 'meal_logs');
    await _deleteSubcollection(babyId, 'meal_plans');
    await _babiesCol.doc(babyId).delete();
    
    // Clear active baby if it was the deleted one
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_activeBabyKey) == babyId) {
      await prefs.remove(_activeBabyKey);
    }
  }

  Future<void> _deleteSubcollection(String babyId, String subcollection) async {
    final snapshots = await _babiesCol.doc(babyId).collection(subcollection).get();
    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateAllergens(String babyId, List<String> allergens) async {
    await _babiesCol.doc(babyId).update({'allergens': allergens});
  }

  Stream<BabyModel?> watchFirstBaby() {
    return _babiesCol.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return BabyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }
}
