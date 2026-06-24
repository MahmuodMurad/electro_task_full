import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/project_repository.dart';
import '../cubit/project_cubit.dart';
import '../cubit/project_state.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/error_widget.dart';
import '../../../../widgets/status_chip.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectCubit(
        ProjectRepository(dio: DioClient.createDio()),
      )..loadProjects(),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  const _ProjectsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('projects'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProjectError) {
            return AppErrorWidget(
              message: state.message.tr(),
              onRetry: () => context.read<ProjectCubit>().loadProjects(),
            );
          }
          if (state is ProjectLoaded) {
            if (state.projects.isEmpty) {
              return EmptyStateWidget(message: 'no_projects'.tr());
            }
            return RefreshIndicator(
              onRefresh: () => context.read<ProjectCubit>().loadProjects(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        project.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (project.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              project.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          StatusChip(status: project.status),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/projects/${project.id}'),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(context),
        icon: const Icon(Icons.add),
        label: Text('add_project'.tr()),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('create_project'.tr()),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'project_title'.tr(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'field_required'.tr();
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'project_description'.tr(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<ProjectCubit>().createProject(
                    titleController.text.trim(),
                    descriptionController.text.trim(),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: Text('save'.tr()),
            ),
          ],
        );
      },
    );
  }
}
