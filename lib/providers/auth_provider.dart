import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, unauthenticated, unverified, authenticated }

// Holds who is logged in and their role. The whole app listens to this
// to decide which screen to show (login, verify email, or the app).
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _profileSubscription;

  AuthStatus _status = AuthStatus.loading;
  AppUser? _appUser;
  bool _isBusy = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get appUser => _appUser;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  bool get isStaff => _appUser?.isStaff ?? false;
  String? get email => _authService.currentUser?.email;

  AuthProvider() {
    _authSubscription = _authService.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    _appUser = null;

    if (user == null) {
      _setStatus(AuthStatus.unauthenticated);
    } else if (!user.emailVerified) {
      _setStatus(AuthStatus.unverified);
    } else {
      _listenToProfile(user.uid);
    }
  }

  // The users/{uid} doc holds the role, so we keep listening to it.
  // If an admin promotes someone to staff it updates straight away.
  void _listenToProfile(String uid) {
    _setStatus(AuthStatus.loading);
    _profileSubscription = _authService.userProfile(uid).listen(
      (profile) {
        if (profile == null) return; // doc is still being created
        _appUser = profile;
        _setStatus(AuthStatus.authenticated);
      },
      onError: (Object e) {
        _errorMessage = 'Could not load your profile.';
        _setStatus(AuthStatus.unauthenticated);
      },
    );
  }

  Future<bool> login(String email, String password) {
    return _runBusy(() => _authService.login(email: email, password: password));
  }

  Future<bool> register(String name, String email, String password) {
    return _runBusy(() => _authService.register(
          name: name,
          email: email,
          password: password,
        ));
  }

  Future<bool> resendVerification() {
    return _runBusy(_authService.sendEmailVerification);
  }

  Future<bool> sendPasswordReset(String email) {
    return _runBusy(() => _authService.sendPasswordReset(email));
  }

  // Called from the verify email screen after the student clicks the link
  Future<bool> checkEmailVerified() async {
    final verified = await _authService.reloadAndCheckVerified();
    if (verified) {
      _listenToProfile(_authService.currentUser!.uid);
    }
    return verified;
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runBusy(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _errorMessage = AuthService.friendlyError(e);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
