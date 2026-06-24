import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.grey[400],
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
              decoration: InputDecoration(
                labelText: 'task_title'.tr(),
                prefixIcon: const Icon(Icons.task_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'field_required'.tr();
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Priority selector
            Text(
              'priority'.tr(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'low', label: Text('priority_low'.tr())),
                ButtonSegment(value: 'medium', label: Text('priority_medium'.tr())),
                ButtonSegment(value: 'high', label: Text('priority_high'.tr())),
              ],
              selected: {_priority},
              onSelectionChanged: (selection) {
                setState(() => _priority = selection.first);
              },
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<TaskCubit>().createTask(
                    _titleController.text.trim(),
                    _priority,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('save'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
