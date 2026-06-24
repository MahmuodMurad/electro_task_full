import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager_electro/core/network/dio_client.dart';
import 'package:task_manager_electro/core/theme/app_colors.dart';
import 'package:task_manager_electro/widgets/fade_in_slide.dart';
import 'package:task_manager_electro/widgets/empty_state_widget.dart';
import 'package:task_manager_electro/widgets/error_widget.dart';
import 'package:task_manager_electro/widgets/status_chip.dart';
import '../../data/repositories/project_repository.dart';
import '../cubit/project_cubit.dart';
import '../cubit/project_state.dart';

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

class _ProjectsView extends StatefulWidget {
  const _ProjectsView();

  @override
  State<_ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<_ProjectsView> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackButtonListener(
      onBackButtonPressed: () async {
        final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
        if (!isCurrent) return false; // Let parent routes handle the back press (pop)

        final now = DateTime.now();
        final backButtonHasNotBeenPressedOrExpired = _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2);
        
        if (backButtonHasNotBeenPressedOrExpired) {
          _lastPressedAt = now;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('press_again_to_exit'.tr()),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return true; // Handled, prevent propagation
        } else {
          SystemNavigator.pop();
          return true; // Handled, prevent propagation
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'projects'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.person_outlined, size: 26),
                onPressed: () => context.push('/profile'),
              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: state.projects.length,
                  itemBuilder: (context, index) {
                    final project = state.projects[index];
                    return FadeInSlide(
                      duration: Duration(milliseconds: 400 + (index * 50).clamp(0, 300)),
                      child: Dismissible(
                        key: Key(project.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 16),
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
                          final projectCubit = context.read<ProjectCubit>();
                          final success = await projectCubit.deleteProject(project.id);
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
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/projects/${project.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                project.title,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? AppColors.textDark : AppColors.textLight,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            StatusChip(status: project.status),
                                          ],
                                        ),
                                        if (project.description.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            project.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  ),
                                ],
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
          onPressed: () => _showCreateProjectDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'add_project'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext parentContext) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(parentContext).brightness == Brightness.dark;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'create_project'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'project_title'.tr(),
                    prefixIcon: const Icon(Icons.work_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'field_required'.tr();
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'project_description'.tr(),
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'cancel'.tr(),
                style: TextStyle(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                minimumSize: const Size(100, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final projectCubit = parentContext.read<ProjectCubit>();
                  final messenger = ScaffoldMessenger.of(parentContext);
                  final success = await projectCubit.createProject(
                    titleController.text.trim(),
                    descriptionController.text.trim(),
                  );
                  if (success && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('error_generic'.tr()),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text('save'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
