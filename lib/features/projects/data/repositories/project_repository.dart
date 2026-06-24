import 'package:dio/dio.dart';
import 'package:task_manager_electro/core/constants/api_constants.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final Dio dio;

  ProjectRepository({required this.dio});

  Future<List<ProjectModel>> getProjects() async {
    final res = await dio.get(ApiConstants.projects);
    return (res.data as List).map((json) => ProjectModel.fromJson(json)).toList();
  }

  Future<ProjectModel> createProject(String title, String description) async {
    final res = await dio.post(ApiConstants.projects, data: {
      'title': title,
      'description': description,
    });
    return ProjectModel.fromJson(res.data);
  }

  Future<ProjectModel> getProject(String id) async {
    final res = await dio.get(ApiConstants.project(id));
    return ProjectModel.fromJson(res.data);
  }

  Future<void> deleteProject(String id) async {
    await dio.delete(ApiConstants.project(id));
  }
}

