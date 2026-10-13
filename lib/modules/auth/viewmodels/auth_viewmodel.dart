import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baby_helper_ai/data/repositories/auth_repository.dart';
import 'package:baby_helper_ai/data/models/user_model.dart';
import 'package:baby_helper_ai/core/errors/api_error_mapper.dart';
import 'package:baby_helper_ai/core/errors/failure.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;

  AuthViewModel(this._authRepo) {
    _authRepo.authStateChanges.listen((user) {
      _firebaseUser = user;
      notifyListeners();
    });
    _firebaseUser = _authRepo.currentUser;
  }

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  Failure? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isLoading => _isLoading;
  Failure? get error => _error;
  String get userName => _userModel?.name ?? _firebaseUser?.displayName ?? 'Parent';

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userModel = await _authRepo.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userModel = await _authRepo.signUpWithEmail(name, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userModel = await _authRepo.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiErrorMapper.map(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<void> loadUserModel() async {
    _userModel = await _authRepo.getCurrentUserModel();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
