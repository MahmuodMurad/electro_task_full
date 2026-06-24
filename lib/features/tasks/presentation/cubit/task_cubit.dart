import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;
  final String projectId;

  TaskCubit(this.repository, this.projectId) : super(TaskInitial());

  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasks(projectId);
      emit(TaskLoaded(tasks));
    } on DioException catch (e) {
      emit(TaskError(e.response?.data['message'] ?? 'error_generic'));
    }
  }

  Future<void> createTask(String title, String priority) async {
    try {
      await repository.createTask(title, projectId, priority);
      await loadTasks();
    } on DioException catch (e) {
      emit(TaskError(e.response?.data['message'] ?? 'error_generic'));
    }
  }

  Future<void> markDone(String taskId) async {
    try {
      await repository.updateTask(taskId, {'status': 'done'});
      await loadTasks();
    } on DioException catch (e) {
      emit(TaskError(e.response?.data['message'] ?? 'error_generic'));
    }
  }
}
