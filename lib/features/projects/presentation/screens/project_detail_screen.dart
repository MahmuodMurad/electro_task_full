import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/dio_client.dart';
import '../../../tasks/data/repositories/task_repository.dart';
import '../../../tasks/presentation/cubit/task_cubit.dart';
import '../../../tasks/presentation/cubit/task_state.dart';
import '../../../tasks/presentation/widgets/add_task_sheet.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/error_widget.dart';
import '../../../../widgets/status_chip.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskCubit(
        TaskRepository(dio: DioClient.createDio()),
        projectId,
      )..loadTasks(),
      child: _ProjectDetailView(projectId: projectId),
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  final String projectId;

  const _ProjectDetailView({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tasks'.tr()),
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TaskError) {
            return AppErrorWidget(
              message: state.message.tr(),
              onRetry: () => context.read<TaskCubit>().loadTasks(),
            );
          }
          if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return EmptyStateWidget(message: 'no_tasks'.tr());
            }
            return RefreshIndicator(
              onRefresh: () => context.read<TaskCubit>().loadTasks(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  final isDone = task.status == 'done';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: IconButton(
                        icon: Icon(
                          isDone ? Icons.check_circle : Icons.circle_outlined,
                          color: isDone ? Colors.green : null,
                          size: 28,
                        ),
                        onPressed: isDone
                            ? null
                            : () => context.read<TaskCubit>().markDone(task.id),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            StatusChip(status: task.status),
                            const SizedBox(width: 8),
                            StatusChip(status: task.priority, isPriority: true),
                          ],
                        ),
                      ),
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => BlocProvider.value(
              value: context.read<TaskCubit>(),
              child: const AddTaskSheet(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text('add_task'.tr()),
      ),
    );
  }
}
