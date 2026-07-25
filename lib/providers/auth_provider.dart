import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.userStream.listen((User? user) async {
      _user = user;
      if (user != null) {
        _userModel = await _authService.getUserData(user.uid);
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    User? result = await _authService.signInWithEmailAndPassword(email, password);
    
    // isLoading is handled by the userStream listener, but we can set it here if auth failed
    if (result == null) {
      _isLoading = false;
      notifyListeners();
    }
    return result != null;
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    
    User? result = await _authService.registerWithEmailAndPassword(email, password, name);
    
    if (result == null) {
      _isLoading = false;
      notifyListeners();
    }
    return result != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
