import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task_model.dart';
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

  Future<bool> createTask(String title, String priority) async {
    final currentState = state;
    try {
      final newTask = await repository.createTask(title, projectId, priority);
      if (currentState is TaskLoaded) {
        final updatedTasks = List<TaskModel>.from(currentState.tasks)..add(newTask);
        emit(TaskLoaded(updatedTasks));
      } else {
        emit(TaskLoaded([newTask]));
      }
      return true;
    } on DioException catch (e) {
      if (currentState is! TaskLoaded) {
        emit(TaskError(e.response?.data['message'] ?? 'error_generic'));
      }
      return false;
    }
  }

  Future<bool> toggleTaskStatus(String taskId) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return false;

    final taskIndex = currentState.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return false;

    final originalTask = currentState.tasks[taskIndex];
    final originalStatus = originalTask.status;
    final newStatus = originalStatus == 'done' ? 'pending' : 'done';

    final updatedTasks = List<TaskModel>.from(currentState.tasks);
    updatedTasks[taskIndex] = originalTask.copyWith(status: newStatus);

    // Optimistically update list to avoid any UI delay
    emit(TaskLoaded(updatedTasks));

    try {
      await repository.updateTask(taskId, {'status': newStatus});
      return true;
    } on DioException catch (_) {
      // Revert state if api call fails
      final revertedTasks = List<TaskModel>.from(currentState.tasks);
      revertedTasks[taskIndex] = originalTask;
      emit(TaskLoaded(revertedTasks));
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return false;

    final originalTasks = List<TaskModel>.from(currentState.tasks);
    final updatedTasks = List<TaskModel>.from(currentState.tasks)
      ..removeWhere((t) => t.id == id);

    emit(TaskLoaded(updatedTasks));

    try {
      await repository.deleteTask(id);
      return true;
    } on DioException catch (_) {
      emit(TaskLoaded(originalTasks));
      return false;
    }
  }
}
