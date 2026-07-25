import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.userStream.listen((UserModel? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
    
    // Stop loading immediately since we are mocking
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    UserModel? result = await _authService.signInWithEmailAndPassword(email, password);
    
    _isLoading = false;
    notifyListeners();
    return result != null;
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    
    UserModel? result = await _authService.registerWithEmailAndPassword(email, password, name);
    
    _isLoading = false;
    notifyListeners();
    return result != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
