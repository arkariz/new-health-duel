import 'package:flutter/material.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Sync Indicator - Shows last health data sync time
///
/// Features:
/// - Last sync timestamp (relative time)
/// - Loading state during sync
/// - Manual refresh button
class SyncIndicator extends StatelessWidget {
  final DateTime lastSyncTime;
  final bool isSyncing;
  final VoidCallback? onRefresh;

  const SyncIndicator({
    required this.lastSyncTime,
    this.isSyncing = false,
    this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Row(
        children: [
          // Sync icon
          if (isSyncing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary,
                ),
              ),
            )
          else
            Icon(
              Icons.sync,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),

          const SizedBox(width: AppSpacing.sm),

          // Last sync text
          Expanded(
            child: Text(
              isSyncing
                  ? 'Syncing health data...'
                  : 'Last synced ${timeago.format(lastSyncTime)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // Refresh button
          if (onRefresh != null && !isSyncing)
            IconButton(
              icon: const Icon(Icons.refresh),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onRefresh,
              tooltip: 'Sync now',
            ),
        ],
      ),
    );
  }
}
