import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:baby_helper_ai/data/services/cry_analysis_service.dart';
import 'package:baby_helper_ai/data/repositories/cry_repository.dart';
import 'package:baby_helper_ai/data/models/cry_result_model.dart';
import 'package:baby_helper_ai/core/errors/api_error_mapper.dart';
import 'package:baby_helper_ai/core/errors/failure.dart';

enum CryRecordingState { idle, recording, analyzing, done, error, noAudioDetected }

class CryViewModel extends ChangeNotifier {
  final CryAnalysisService _analysisService;
  final CryRepository _cryRepo;

  CryViewModel(this._analysisService, this._cryRepo);

  final AudioRecorder _recorder = AudioRecorder();
  CryRecordingState _state = CryRecordingState.idle;
  CryResultModel? _result;
  Failure? _error;
  String? _audioPath;
  String? _silenceMessage;
  List<CryResultModel> _history = [];

  CryRecordingState get state => _state;
  CryResultModel? get result => _result;
  Failure? get error => _error;
  bool get isRecording => _state == CryRecordingState.recording;
  bool get isAnalyzing => _state == CryRecordingState.analyzing;
  bool get isNoAudioDetected => _state == CryRecordingState.noAudioDetected;
  String? get silenceMessage => _silenceMessage;
  List<CryResultModel> get history => _history;

  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _audioPath = '${dir.path}/cry_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: _audioPath!,
        );
        _state = CryRecordingState.recording;
        _result = null;
        _error = null;
        _silenceMessage = null;
        notifyListeners();
      } else {
        _error = const PermissionFailure('Microphone permission denied');
        _state = CryRecordingState.error;
        notifyListeners();
      }
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _state = CryRecordingState.error;
      notifyListeners();
    }
  }

  Future<CryResultModel?> stopAndAnalyze() async {
    try {
      final path = await _recorder.stop();
      if (path == null) {
        _error = const UnknownFailure('Recording failed');
        _state = CryRecordingState.error;
        notifyListeners();
        return null;
      }

      _audioPath = path;
      _state = CryRecordingState.analyzing;
      notifyListeners();

      _result = await _analysisService.analyzeAudio(_audioPath!);
      _state = CryRecordingState.done;
      notifyListeners();

      // Cleanup temp file
      try {
        await File(_audioPath!).delete();
      } catch (_) {}

      return _result;
    } on AudioSilenceException catch (e) {
      _silenceMessage = e.message;
      _state = CryRecordingState.noAudioDetected;
      notifyListeners();
      // Cleanup temp file
      try {
        if (_audioPath != null) await File(_audioPath!).delete();
      } catch (_) {}
      return null;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _state = CryRecordingState.error;
      notifyListeners();
      return null;
    }
  }

  Future<void> saveResult(String babyId) async {
    if (_result == null) return;
    try {
      await _cryRepo.saveResult(babyId, _result!);
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      notifyListeners();
    }
  }

  Future<void> loadHistory(String babyId) async {
    try {
      _history = await _cryRepo.getResults(babyId);
      notifyListeners();
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      notifyListeners();
    }
  }

  void reset() {
    _state = CryRecordingState.idle;
    _result = null;
    _error = null;
    _silenceMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _analysisService.dispose();
    super.dispose();
  }
}
