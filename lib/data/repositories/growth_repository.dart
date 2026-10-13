import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baby_helper_ai/data/models/growth_measurement_model.dart';

class GrowthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GrowthRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference _measurementsCol(String babyId) => _firestore
      .collection('users')
      .doc(_uid)
      .collection('babies')
      .doc(babyId)
      .collection('measurements');

  Future<GrowthMeasurementModel> addMeasurement(
      String babyId, GrowthMeasurementModel measurement) async {
    final doc = await _measurementsCol(babyId).add(measurement.toMap());
    return GrowthMeasurementModel(
      id: doc.id,
      height: measurement.height,
      weight: measurement.weight,
      headCircumference: measurement.headCircumference,
      date: measurement.date,
      heightZScore: measurement.heightZScore,
      weightZScore: measurement.weightZScore,
      headZScore: measurement.headZScore,
      bmiZScore: measurement.bmiZScore,
    );
  }

  Future<List<GrowthMeasurementModel>> getMeasurements(String babyId) async {
    final snapshot = await _measurementsCol(babyId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return GrowthMeasurementModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<GrowthMeasurementModel?> getLatestMeasurement(String babyId) async {
    final snapshot = await _measurementsCol(babyId)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return GrowthMeasurementModel.fromMap(
        snapshot.docs.first.data() as Map<String, dynamic>,
        snapshot.docs.first.id);
  }

  Future<void> updateMeasurement(
      String babyId, GrowthMeasurementModel measurement) async {
    await _measurementsCol(babyId).doc(measurement.id).update(measurement.toMap());
  }

  Future<void> deleteMeasurement(String babyId, String measurementId) async {
    await _measurementsCol(babyId).doc(measurementId).delete();
  }
}
