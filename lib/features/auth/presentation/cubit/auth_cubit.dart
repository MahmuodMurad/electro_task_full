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

  @override
  Future<void> close() {
    _unauthorizedSubscription?.cancel();
    return super.close();
  }
}
