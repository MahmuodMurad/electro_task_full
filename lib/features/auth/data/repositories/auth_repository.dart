import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:task_manager_electro/core/constants/api_constants.dart';
import 'package:task_manager_electro/core/constants/storage_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthRepository({required this.dio, required this.storage});

  Future<UserModel> login(String email, String password) async {
    final res = await dio.post(ApiConstants.login, data: {'email': email, 'password': password});
    await storage.write(key: StorageConstants.jwtToken, value: res.data['accessToken']);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> register(String name, String email, String password) async {
    final res = await dio.post(ApiConstants.register, data: {'name': name, 'email': email, 'password': password});
    await storage.write(key: StorageConstants.jwtToken, value: res.data['accessToken']);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel?> getMe() async {
    final token = await storage.read(key: StorageConstants.jwtToken);
    if (token == null) return null;
    final res = await dio.get(ApiConstants.me);
    return UserModel.fromJson(res.data);
  }

  Future<void> logout() async {
    await storage.delete(key: StorageConstants.jwtToken);
  }
}


