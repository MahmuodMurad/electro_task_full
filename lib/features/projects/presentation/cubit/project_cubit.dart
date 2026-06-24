import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> createProject(String title, String description) async {
    try {
      await repository.createProject(title, description);
      await loadProjects();
    } on DioException catch (e) {
      emit(ProjectError(e.response?.data['message'] ?? 'error_generic'));
    }
  }
}
