import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await repository.getMe();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(email, password);
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'error_generic';
      emit(AuthError(msg));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await repository.register(name, email, password);
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'error_generic';
      emit(AuthError(msg));
    }
  }

  Future<void> logout() async {
    await repository.logout();
    emit(AuthUnauthenticated());
  }
}
