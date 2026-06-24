import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_electro/core/network/dio_client.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  StreamSubscription<void>? _unauthorizedSubscription;

  AuthCubit(this.repository) : super(AuthInitial()) {
    _unauthorizedSubscription = DioClient.onUnauthorized.stream.listen((_) {
      logout();
    });
  }

  Future<void> checkAuth() async {
    emit(AuthChecking());
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
      final serverMsg = e.response?.data['message']?.toString() ?? '';
      String msg = 'error_generic';
      if (serverMsg.toLowerCase().contains('invalid') ||
          serverMsg.toLowerCase().contains('credential') ||
          serverMsg.toLowerCase().contains('wrong') ||
          serverMsg.toLowerCase().contains('password')) {
        msg = 'error_invalid_credentials';
      }
      emit(AuthError(msg));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await repository.register(name, email, password);
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final serverMsg = e.response?.data['message']?.toString() ?? '';
      String msg = 'error_generic';
      if (serverMsg.toLowerCase().contains('exist') ||
          serverMsg.toLowerCase().contains('already') ||
          serverMsg.toLowerCase().contains('conflict') ||
          serverMsg.toLowerCase().contains('duplicate')) {
        msg = 'error_user_exists';
      }
      emit(AuthError(msg));
    }
  }

  Future<void> logout() async {
    await repository.logout();
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _unauthorizedSubscription?.cancel();
    return super.close();
  }
}
