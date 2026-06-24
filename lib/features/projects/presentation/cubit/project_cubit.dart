import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';
import 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final ProjectRepository repository;

  ProjectCubit(this.repository) : super(ProjectInitial());

  Future<void> loadProjects() async {
    emit(ProjectLoading());
    try {
      final projects = await repository.getProjects();
      emit(ProjectLoaded(projects));
    } on DioException catch (e) {
      emit(ProjectError(e.response?.data['message'] ?? 'error_generic'));
    }
  }

  Future<bool> createProject(String title, String description) async {
    final currentState = state;
    try {
      final newProject = await repository.createProject(title, description);
      if (currentState is ProjectLoaded) {
        final updatedProjects = List<ProjectModel>.from(currentState.projects)..add(newProject);
        emit(ProjectLoaded(updatedProjects));
      } else {
        emit(ProjectLoaded([newProject]));
      }
      return true;
    } on DioException catch (e) {
      if (currentState is! ProjectLoaded) {
        emit(ProjectError(e.response?.data['message'] ?? 'error_generic'));
      }
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    final currentState = state;
    if (currentState is! ProjectLoaded) return false;

    final originalProjects = List<ProjectModel>.from(currentState.projects);
    final updatedProjects = List<ProjectModel>.from(currentState.projects)
      ..removeWhere((p) => p.id == id);

    emit(ProjectLoaded(updatedProjects));

    try {
      await repository.deleteProject(id);
      return true;
    } on DioException catch (_) {
      emit(ProjectLoaded(originalProjects));
      return false;
    }
  }
}
