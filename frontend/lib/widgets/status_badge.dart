import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final String type; // 'priority', 'status', 'approval'

  const StatusBadge({
    super.key,
    required this.label,
    this.type = 'status',
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    final lower = label.toLowerCase();

    if (type == 'priority') {
      if (lower == 'critical') {
        bg = AppTheme.roseDanger.withOpacity(0.18);
        fg = AppTheme.roseDanger;
      } else if (lower == 'high') {
        bg = AppTheme.amberWarning.withOpacity(0.18);
        fg = AppTheme.amberWarning;
      } else if (lower == 'medium') {
        bg = AppTheme.tealAccent.withOpacity(0.18);
        fg = AppTheme.tealAccent;
      } else {
        bg = AppTheme.textMuted.withOpacity(0.18);
        fg = AppTheme.textMuted;
      }
    } else if (type == 'approval') {
      if (lower == 'approved') {
        bg = AppTheme.emeraldSuccess.withOpacity(0.18);
        fg = AppTheme.emeraldSuccess;
      } else if (lower == 'revision requested') {
        bg = AppTheme.roseDanger.withOpacity(0.18);
        fg = AppTheme.roseDanger;
      } else {
        bg = AppTheme.amberWarning.withOpacity(0.18);
        fg = AppTheme.amberWarning;
      }
    } else {
      if (lower == 'completed' || lower == 'paid') {
        bg = AppTheme.emeraldSuccess.withOpacity(0.18);
        fg = AppTheme.emeraldSuccess;
      } else if (lower == 'in progress') {
        bg = AppTheme.goldPrimary.withOpacity(0.18);
        fg = AppTheme.goldPrimary;
      } else if (lower == 'to do' || lower == 'pending') {
        bg = AppTheme.tealAccent.withOpacity(0.18);
        fg = AppTheme.tealAccent;
      } else if (lower == 'low stock' || lower == 'overdue') {
        bg = AppTheme.roseDanger.withOpacity(0.18);
        fg = AppTheme.roseDanger;
      } else {
        bg = AppTheme.textMuted.withOpacity(0.18);
        fg = AppTheme.textMuted;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
