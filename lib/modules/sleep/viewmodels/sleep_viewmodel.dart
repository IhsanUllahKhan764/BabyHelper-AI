import 'package:flutter/material.dart';
import 'package:baby_helper_ai/data/repositories/sleep_repository.dart';
import 'package:baby_helper_ai/data/models/sleep_session_model.dart';
import 'package:baby_helper_ai/core/errors/api_error_mapper.dart';
import 'package:baby_helper_ai/core/errors/failure.dart';

class SleepViewModel extends ChangeNotifier {
  final SleepRepository _sleepRepo;

  SleepViewModel(this._sleepRepo);

  List<SleepSessionModel> _sessions = [];
  List<SleepSessionModel> _todaySessions = [];
  List<SleepSessionModel> _weekSessions = [];
  bool _isLoading = false;
  Failure? _error;

  List<SleepSessionModel> get sessions => _sessions;
  List<SleepSessionModel> get todaySessions => _todaySessions;
  List<SleepSessionModel> get weekSessions => _weekSessions;
  bool get isLoading => _isLoading;
  Failure? get error => _error;

  // === Statistics ===

  double get todayTotalHours {
    double total = 0;
    for (final s in _todaySessions) {
      total += s.durationHours;
    }
    return total;
  }

  int get todayNapCount => _todaySessions.length;

  double get longestStretchHours {
    if (_todaySessions.isEmpty) return 0;
    double longest = 0;
    for (final s in _todaySessions) {
      if (s.durationHours > longest) longest = s.durationHours;
    }
    return longest;
  }

  double get avgSessionHours {
    if (_todaySessions.isEmpty) return 0;
    return todayTotalHours / _todaySessions.length;
  }

  double get weekAvgHoursPerDay {
    if (_weekSessions.isEmpty) return 0;
    final dayTotals = <int, double>{};
    for (final s in _weekSessions) {
      final dayKey = s.startTime.day;
      dayTotals[dayKey] = (dayTotals[dayKey] ?? 0) + s.durationHours;
    }
    if (dayTotals.isEmpty) return 0;
    final totalHours = dayTotals.values.fold(0.0, (a, b) => a + b);
    return totalHours / dayTotals.length;
  }

  Map<String, double> get sleepDistribution {
    if (_todaySessions.isEmpty) return {};
    final dist = <String, double>{};
    for (final s in _todaySessions) {
      dist[s.qualityLabel] = (dist[s.qualityLabel] ?? 0) + s.durationHours;
    }
    return dist;
  }

  List<Map<String, dynamic>> get weeklyTrends {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      double total = 0;
      for (final s in _weekSessions) {
        if (s.startTime.day == day.day &&
            s.startTime.month == day.month &&
            s.startTime.year == day.year) {
          total += s.durationHours;
        }
      }
      return {'day': days[i], 'hours': total};
    });
  }

  // === Sleep Tips (age-based) ===

  List<String> getSleepTips(int ageInMonths) {
    final tips = <String>[];

    // Universal tips
    tips.add('🌙 Keep the room dark and cool (68-72°F / 20-22°C) for better sleep quality.');
    tips.add('📱 Avoid screen time at least 1 hour before bedtime.');
    tips.add('🛁 A warm bath before bed can help signal it\'s time to sleep.');

    if (ageInMonths <= 3) {
      tips.add('👶 Newborns sleep 14-17 hours per day in short bursts of 2-4 hours.');
      tips.add('🍼 Night feedings are normal — your baby\'s stomach is still small.');
      tips.add('🎵 White noise mimics womb sounds and helps newborns sleep longer.');
      tips.add('😴 Watch for sleep cues: yawning, fussing, rubbing eyes.');
    } else if (ageInMonths <= 6) {
      tips.add('👶 At ${ageInMonths}mo, aim for 12-16 hours of total sleep including naps.');
      tips.add('🕐 Start establishing a consistent bedtime routine (bath → book → bed).');
      tips.add('💤 Encourage self-soothing by putting baby down drowsy but awake.');
      tips.add('☀️ Expose baby to natural light during the day to regulate circadian rhythm.');
    } else if (ageInMonths <= 12) {
      tips.add('👶 At ${ageInMonths}mo, most babies need 12-15 hours including 2 naps.');
      tips.add('🕐 Aim for a consistent bedtime between 6:30-7:30 PM.');
      tips.add('🧸 A lovey or comfort object can help with sleep transitions.');
      tips.add('🚫 Avoid letting baby stay awake more than 3-4 hours between naps.');
    } else {
      tips.add('👶 Toddlers need 11-14 hours of sleep including 1-2 naps.');
      tips.add('📖 Reading a story before bed creates positive sleep associations.');
      tips.add('⏰ Keep nap times consistent — aim for early afternoon naps.');
      tips.add('🏃 Active play during the day promotes better nighttime sleep.');
    }

    return tips;
  }

  // === CRUD ===

  Future<void> loadSessions(String babyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _sessions = await _sleepRepo.getSessions(babyId);
      _todaySessions = await _sleepRepo.getTodaySessions(babyId);
      _weekSessions = await _sleepRepo.getWeekSessions(babyId);
    } catch (e) {
      _error = ApiErrorMapper.map(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSession(
    String babyId, {
    required DateTime startTime,
    required DateTime endTime,
    required SleepQuality quality,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final session = SleepSessionModel(
        id: '',
        startTime: startTime,
        endTime: endTime,
        quality: quality,
        notes: notes,
      );
      await _sleepRepo.addSession(babyId, session);
      await loadSessions(babyId);
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSession(String babyId, String sessionId) async {
    try {
      await _sleepRepo.deleteSession(babyId, sessionId);
      _sessions.removeWhere((s) => s.id == sessionId);
      _todaySessions.removeWhere((s) => s.id == sessionId);
      _weekSessions.removeWhere((s) => s.id == sessionId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      notifyListeners();
      return false;
    }
  }
}
