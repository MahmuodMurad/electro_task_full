import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_electro/core/network/dio_client.dart';
import 'package:task_manager_electro/core/theme/app_colors.dart';
import 'package:task_manager_electro/widgets/fade_in_slide.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'tasks'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  final isDone = task.status == 'done';
                  
                  // Get priority accent color
                  Color priorityColor;
                  switch (task.priority) {
                    case 'high':
                      priorityColor = AppColors.priorityHigh;
                      break;
                    case 'medium':
                      priorityColor = AppColors.priorityMedium;
                      break;
                    default:
                      priorityColor = AppColors.priorityLow;
                  }

                  return FadeInSlide(
                    duration: Duration(milliseconds: 400 + (index * 50).clamp(0, 300)),
                    child: Dismissible(
                      key: Key(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        alignment: AlignmentDirectional.centerEnd,
                        padding: const EdgeInsetsDirectional.only(end: 20.0),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) async {
                        final taskCubit = context.read<TaskCubit>();
                        final success = await taskCubit.deleteTask(task.id);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('delete_success'.tr()),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            // Side accent border
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: priorityColor,
                                  width: 5.0,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              leading: AnimatedCheckbox(
                                isChecked: isDone,
                                onTap: () => context.read<TaskCubit>().toggleTaskStatus(task.id),
                              ),
                              title: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                                      : (isDark ? AppColors.textDark : AppColors.textLight),
                                  decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                                child: Text(task.title),
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
                          ),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => BlocProvider.value(
              value: context.read<TaskCubit>(),
              child: const AddTaskSheet(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'add_task'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}

class AnimatedCheckbox extends StatefulWidget {
  final bool isChecked;
  final VoidCallback onTap;

  const AnimatedCheckbox({
    super.key,
    required this.isChecked,
    required this.onTap,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isChecked ? AppColors.statusDone : Colors.transparent,
            border: Border.all(
              color: widget.isChecked
                  ? AppColors.statusDone
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 2.0,
            ),
          ),
          child: widget.isChecked
              ? const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
