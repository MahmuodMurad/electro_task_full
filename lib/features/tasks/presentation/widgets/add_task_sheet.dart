import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_electro/core/theme/app_colors.dart';
import '../cubit/task_cubit.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _priority = 'medium';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'add_task'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Task title
            TextFormField(
              controller: _titleController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'task_title'.tr(),
                prefixIcon: const Icon(Icons.task_alt_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'field_required'.tr();
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Priority selector
            Text(
              'priority'.tr(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'low', label: Text('priority_low'.tr())),
                ButtonSegment(value: 'medium', label: Text('priority_medium'.tr())),
                ButtonSegment(value: 'high', label: Text('priority_high'.tr())),
              ],
              selected: {_priority},
              onSelectionChanged: _isLoading
                  ? null
                  : (selection) {
                      setState(() => _priority = selection.first);
                    },
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        final taskCubit = context.read<TaskCubit>();
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await taskCubit.createTask(
                          _titleController.text.trim(),
                          _priority,
                        );
                        if (success) {
                          if (navigator.context.mounted) {
                            navigator.pop();
                          }
                        } else {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('error_generic'.tr()),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('save'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
