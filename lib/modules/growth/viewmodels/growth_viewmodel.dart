import 'package:flutter/material.dart';
import 'package:baby_helper_ai/data/repositories/growth_repository.dart';
import 'package:baby_helper_ai/data/services/who_standards_service.dart';
import 'package:baby_helper_ai/data/models/growth_measurement_model.dart';
import 'package:baby_helper_ai/data/models/baby_model.dart';
import 'package:baby_helper_ai/core/errors/api_error_mapper.dart';
import 'package:baby_helper_ai/core/errors/failure.dart';

class GrowthViewModel extends ChangeNotifier {
  final GrowthRepository _growthRepo;
  final WhoStandardsService _whoService;

  GrowthViewModel(this._growthRepo, this._whoService);

  List<GrowthMeasurementModel> _measurements = [];
  GrowthMeasurementModel? _latest;
  bool _isLoading = false;
  Failure? _error;

  List<GrowthMeasurementModel> get measurements => _measurements;
  GrowthMeasurementModel? get latest => _latest;
  bool get isLoading => _isLoading;
  Failure? get error => _error;

  /// Overall growth status based on latest z-scores.
  /// Returns "Normal Growth" / "Needs Attention" / null.
  String? get overallGrowthStatus {
    if (_latest == null) return null;
    final wz = _latest!.weightZScore;
    final hz = _latest!.heightZScore;
    final headZ = _latest!.headZScore;

    if (wz == null && hz == null && headZ == null) return null;

    final hasWarning = WhoStandardsService.hasWarning(wz) ||
        WhoStandardsService.hasWarning(hz) ||
        WhoStandardsService.hasWarning(headZ);

    return hasWarning ? 'Needs Attention' : 'Normal Growth';
  }

  bool get isGrowthNormal => overallGrowthStatus == 'Normal Growth';

  /// Detailed summary text for the status banner.
  String get growthSummary {
    if (_latest == null) return '';
    final parts = <String>[];
    if (_latest!.weightZScore != null) {
      parts.add('Weight: ${WhoStandardsService.getWeightStatus(_latest!.weightZScore)}');
    }
    if (_latest!.heightZScore != null) {
      parts.add('Height: ${WhoStandardsService.getHeightStatus(_latest!.heightZScore)}');
    }
    if (_latest!.headZScore != null) {
      parts.add('Head: ${WhoStandardsService.getHeadStatus(_latest!.headZScore)}');
    }
    return parts.join(' • ');
  }

  Future<void> loadMeasurements(String babyId, {BabyModel? baby}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _measurements = await _growthRepo.getMeasurements(babyId);

      // Auto-seed from birth data if no measurements exist
      if (_measurements.isEmpty && baby != null && baby.birthWeight != null && baby.birthHeight != null) {
        var seedMeasurement = GrowthMeasurementModel(
          id: '',
          height: baby.birthHeight!,
          weight: baby.birthWeight!,
          headCircumference: baby.birthHeadCircumference ?? 35.0,
          date: baby.dateOfBirth,
        );
        seedMeasurement = _whoService.calculateZScores(seedMeasurement, baby);
        await _growthRepo.addMeasurement(babyId, seedMeasurement);
        _measurements = await _growthRepo.getMeasurements(babyId);
      }

      _latest = _measurements.isNotEmpty ? _measurements.first : null;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMeasurement(
    String babyId,
    BabyModel baby, {
    required double height,
    required double weight,
    required double headCircumference,
    required DateTime date,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      var measurement = GrowthMeasurementModel(
        id: '',
        height: height,
        weight: weight,
        headCircumference: headCircumference,
        date: date,
      );

      // Calculate WHO z-scores
      measurement = _whoService.calculateZScores(measurement, baby);

      await _growthRepo.addMeasurement(babyId, measurement);
      await loadMeasurements(babyId);
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMeasurement(
    String babyId,
    BabyModel baby,
    GrowthMeasurementModel existing, {
    required double height,
    required double weight,
    required double headCircumference,
    required DateTime date,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      var measurement = GrowthMeasurementModel(
        id: existing.id,
        height: height,
        weight: weight,
        headCircumference: headCircumference,
        date: date,
      );

      measurement = _whoService.calculateZScores(measurement, baby);

      await _growthRepo.updateMeasurement(babyId, measurement);
      await loadMeasurements(babyId);
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMeasurement(String babyId, String measurementId) async {
    try {
      await _growthRepo.deleteMeasurement(babyId, measurementId);
      _measurements.removeWhere((m) => m.id == measurementId);
      _latest = _measurements.isNotEmpty ? _measurements.first : null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      notifyListeners();
      return false;
    }
  }
}
