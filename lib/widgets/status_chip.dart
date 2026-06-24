import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool isPriority;

  const StatusChip({
    super.key,
    required this.status,
    this.isPriority = false,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _getLabel(),
        style: TextStyle(
          color: _getColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _getColor().withValues(alpha: 0.12),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _getLabel() {
    if (isPriority) {
      switch (status) {
        case 'low':
          return 'priority_low'.tr();
        case 'medium':
          return 'priority_medium'.tr();
        case 'high':
          return 'priority_high'.tr();
        default:
          return status;
      }
    }
    switch (status) {
      case 'pending':
        return 'status_pending'.tr();
      case 'in_progress':
        return 'status_in_progress'.tr();
      case 'done':
        return 'status_done'.tr();
      case 'active':
        return 'active'.tr();
      case 'completed':
        return 'completed'.tr();
      case 'archived':
        return 'archived'.tr();
      default:
        return status;
    }
  }

  Color _getColor() {
    if (isPriority) {
      switch (status) {
        case 'low':
          return Colors.blue;
        case 'medium':
          return Colors.orange;
        case 'high':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'done':
        return Colors.green;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
