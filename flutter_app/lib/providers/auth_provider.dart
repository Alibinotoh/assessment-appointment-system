import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? counselorId;
  final String? fullName;
  final String? email;

  AuthState({
    this.isAuthenticated = false,
    this.token,
    this.counselorId,
    this.fullName,
    this.email,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? counselorId,
    String? fullName,
    String? email,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      counselorId: counselorId ?? this.counselorId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final counselorId = prefs.getString('counselor_id');
    final fullName = prefs.getString('full_name');
    final email = prefs.getString('email');

    if (token != null) {
      state = AuthState(
        isAuthenticated: true,
        token: token,
        counselorId: counselorId,
        fullName: fullName,
        email: email,
      );
    }
  }

  Future<void> login({
    required String token,
    required String counselorId,
    required String fullName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('counselor_id', counselorId);
    await prefs.setString('full_name', fullName);
    await prefs.setString('email', email);

    state = AuthState(
      isAuthenticated: true,
      token: token,
      counselorId: counselorId,
      fullName: fullName,
      email: email,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('counselor_id');
    await prefs.remove('full_name');
    await prefs.remove('email');

    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
