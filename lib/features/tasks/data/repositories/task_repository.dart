import 'package:dio/dio.dart';
import 'package:task_manager_electro/core/constants/api_constants.dart';
import '../models/task_model.dart';

class TaskRepository {
  final Dio dio;

  TaskRepository({required this.dio});

  Future<List<TaskModel>> getTasks(String projectId) async {
    final res = await dio.get(ApiConstants.tasksForProject(projectId));
    return (res.data as List).map((json) => TaskModel.fromJson(json)).toList();
  }

  Future<TaskModel> createTask(String title, String projectId, String priority) async {
    final res = await dio.post(ApiConstants.tasks, data: {
      'title': title,
      'project': projectId,
      'priority': priority,
    });
    return TaskModel.fromJson(res.data);
  }

  Future<TaskModel> updateTask(String taskId, Map<String, dynamic> data) async {
    final res = await dio.patch(ApiConstants.task(taskId), data: data);
    return TaskModel.fromJson(res.data);
  }
}

