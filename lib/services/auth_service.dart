import 'dart:async';
import '../models/user_model.dart';

class AuthService {
  // MOCK STATE - Firebase is bypassed
  final _userController = StreamController<UserModel?>.broadcast();
  UserModel? _mockUser;

  Stream<UserModel?> get userStream => _userController.stream;
  
  String? get currentUserUid => _mockUser?.uid;

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    _mockUser = UserModel(uid: 'mock_uid_123', email: email, name: 'Test User');
    _userController.add(_mockUser);
    return _mockUser;
  }

  Future<UserModel?> registerWithEmailAndPassword(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockUser = UserModel(uid: 'mock_uid_123', email: email, name: name);
    _userController.add(_mockUser);
    return _mockUser;
  }

  Future<UserModel?> getUserData(String uid) async {
    return _mockUser;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockUser = null;
    _userController.add(null);
  }
}
