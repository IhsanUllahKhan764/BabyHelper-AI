import 'package:flutter/material.dart';
import 'package:baby_helper_ai/data/repositories/baby_repository.dart';
import 'package:baby_helper_ai/data/repositories/cry_repository.dart';
import 'package:baby_helper_ai/data/repositories/growth_repository.dart';
import 'package:baby_helper_ai/data/repositories/sleep_repository.dart';
import 'package:baby_helper_ai/data/repositories/nutrition_repository.dart';
import 'package:baby_helper_ai/data/models/baby_model.dart';
import 'package:baby_helper_ai/data/models/cry_result_model.dart';
import 'package:baby_helper_ai/data/models/growth_measurement_model.dart';
import 'package:baby_helper_ai/data/models/sleep_session_model.dart';
import 'package:baby_helper_ai/core/errors/api_error_mapper.dart';
import 'package:baby_helper_ai/core/errors/failure.dart';

class HomeViewModel extends ChangeNotifier {
  final BabyRepository _babyRepo;
  final CryRepository _cryRepo;
  final GrowthRepository _growthRepo;
  final SleepRepository _sleepRepo;
  // ignore: unused_field
  final NutritionRepository _nutritionRepo;

  HomeViewModel(this._babyRepo, this._cryRepo, this._growthRepo, this._sleepRepo, this._nutritionRepo);

  BabyModel? _baby;
  List<BabyModel> _allBabies = [];
  List<CryResultModel> _recentCryResults = [];
  GrowthMeasurementModel? _latestMeasurement;
  List<SleepSessionModel> _todaySleep = [];
  bool _isLoading = false;
  Failure? _error;

  BabyModel? get baby => _baby;
  List<BabyModel> get allBabies => _allBabies;
  List<CryResultModel> get recentCryResults => _recentCryResults;
  GrowthMeasurementModel? get latestMeasurement => _latestMeasurement;
  List<SleepSessionModel> get todaySleep => _todaySleep;
  bool get isLoading => _isLoading;
  Failure? get error => _error;

  double get todaySleepHours {
    double total = 0;
    for (final session in _todaySleep) {
      total += session.durationHours;
    }
    return total;
  }

  String get aiTip {
    final tips = [
      '💡 Respond to your baby\'s cries within 30 seconds. This builds trust and reduces overall crying duration over time.',
      '💡 Skin-to-skin contact for 20 minutes daily can reduce stress hormones and improve bonding.',
      '💡 Babies need 14-17 hours of sleep per day in the first 3 months. Establish a consistent bedtime routine.',
      '💡 Introduce solid foods around 6 months. Start with single-ingredient purees to identify allergies.',
      '💡 Tummy time starting from birth helps strengthen neck and shoulder muscles. Start with 3-5 minutes.',
      '💡 Track your baby\'s growth monthly. Consistent growth trends matter more than single measurements.',
      '💡 White noise can help babies sleep. It mimics the sounds they heard in the womb.',
      '💡 Breastfed babies generally need to eat every 2-3 hours. Watch for hunger cues like lip smacking.',
    ];
    final index = DateTime.now().day % tips.length;
    return tips[index];
  }

  List<Map<String, dynamic>> get recentActivity {
    final activities = <Map<String, dynamic>>[];

    for (final cry in _recentCryResults) {
      activities.add({
        'id': cry.id,
        'module': 'Cry Analyzer',
        'icon': Icons.mic,
        'summary': 'Detected: ${cry.categoryLabel}',
        'time': cry.timestamp,
      });
    }

    if (_latestMeasurement != null) {
      activities.add({
        'id': _latestMeasurement!.id,
        'module': 'Growth Tracker',
        'icon': Icons.show_chart,
        'summary': '${_latestMeasurement!.weight}kg, ${_latestMeasurement!.height}cm',
        'time': _latestMeasurement!.date,
      });
    }

    for (final sleep in _todaySleep.take(1)) {
      activities.add({
        'id': sleep.id,
        'module': 'Sleep Monitor',
        'icon': Icons.bedtime,
        'summary': '${sleep.durationHours.toStringAsFixed(1)}h ${sleep.qualityLabel}',
        'time': sleep.startTime,
      });
    }

    activities.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    return activities.take(10).toList();
  }


  Future<void> deleteActivity(String id, String module) async {
    if (_baby == null) return;
    
    // Optimistic UI update to prevent Dismissible tree error
    if (module == 'Cry Analyzer') {
      _recentCryResults.removeWhere((cry) => cry.id == id);
    } else if (module == 'Growth Tracker') {
      if (_latestMeasurement?.id == id) {
        _latestMeasurement = null;
      }
    } else if (module == 'Sleep Monitor') {
      _todaySleep.removeWhere((sleep) => sleep.id == id);
    }
    notifyListeners();

    try {
      if (module == 'Cry Analyzer') {
        await _cryRepo.deleteResult(_baby!.id, id);
      } else if (module == 'Growth Tracker') {
        await _growthRepo.deleteMeasurement(_baby!.id, id);
      } else if (module == 'Sleep Monitor') {
        await _sleepRepo.deleteSession(_baby!.id, id);
      }
      await loadDashboard(showLoading: false); // Reload silently after deletion
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      await loadDashboard(showLoading: false); // Revert optimistic update silently
    }
  }

  Future<void> loadDashboard({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _allBabies = await _babyRepo.getBabies();
      _baby = await _babyRepo.getActiveBaby();
      if (_baby != null) {
        try {
          _recentCryResults = await _cryRepo.getRecentResults(_baby!.id);
        } catch (_) {
          _recentCryResults = [];
        }
        try {
          _latestMeasurement = await _growthRepo.getLatestMeasurement(_baby!.id);
        } catch (_) {
          _latestMeasurement = null;
        }
        try {
          _todaySleep = await _sleepRepo.getTodaySessions(_baby!.id);
        } catch (_) {
          _todaySleep = [];
        }
      }
    } catch (e) {
      _error = ApiErrorMapper.map(e);
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> switchBaby(String babyId) async {
    await _babyRepo.setActiveBaby(babyId);
    await loadDashboard();
  }

  Future<void> deleteBaby(String babyId) async {
    await _babyRepo.deleteBaby(babyId);
    await loadDashboard();
  }

  void setBaby(BabyModel baby) {
    _baby = baby;
    if (!_allBabies.any((b) => b.id == baby.id)) {
      _allBabies.add(baby);
    }
    notifyListeners();
  }
}
