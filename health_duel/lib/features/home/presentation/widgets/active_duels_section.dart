import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/core/utils/extensions/extensions.dart';
import 'package:health_duel/features/duel/domain/entities/duel.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_bloc.dart';
import 'package:health_duel/features/duel/presentation/bloc/duel_list_state.dart';
import 'package:health_duel/features/duel/presentation/widgets/duel_arena_widgets.dart';

class ActiveDuelsSection extends StatelessWidget {
  const ActiveDuelsSection({
    super.key,
    required this.currentUserId,
    required this.onTapSeeAll,
    required this.onTapDuelCard,
  });

  final String currentUserId;
  final VoidCallback onTapSeeAll;
  final void Function(String duelId) onTapDuelCard;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DuelListBloc, DuelListState>(
      buildWhen: (prev, curr) {
        if (prev is DuelListLoaded && curr is DuelListLoaded) {
          return prev.activeDuels != curr.activeDuels;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        final activeDuels = state is DuelListLoaded ? state.activeDuels : <Duel>[];

        final theme = Theme.of(context);
        final primary = theme.colorScheme.primary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            _renderHeader(theme, context, primary),
            const SizedBox(height: AppSpacing.sm),

            if (activeDuels.isEmpty)
              _buildEmptyState(context)
            else
              _buildDuelCard(context, activeDuels.first),
          ],
        );
      },
    );
  }

  Widget _renderHeader(ThemeData theme, BuildContext context, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Active Duels', style: theme.textTheme.titleLarge),
        TextButton(
          onPressed: onTapSeeAll,
          child: Text(
            'See all',
            style: theme.textTheme.labelMedium?.copyWith(color: primary),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: context.appColors.divider),
      ),
      child: Center(
        child: Text(
          'No active duels — challenge someone!',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildDuelCard(BuildContext context, Duel duel) {
    final isWinning = duel.isUserWinning(currentUserId);
    final diff = duel.stepDifference;
    final (leadText, leadColor) = isWinning == true
        ? ("You're winning by ${diff.withCommas} steps", context.appColors.success)
        : isWinning == false
            ? ('Trailing by ${diff.withCommas} steps', context.appColors.opponent)
            : ("It's a tie!", context.appColors.warning);

    return DuelActiveCard(
      duel: duel,
      currentUserId: currentUserId,
      onTap: () => onTapDuelCard(duel.id),
      footerTimeText: '${_formatRemaining(duel.remainingTime)} remaining',
      footerTrailingText: leadText,
      footerTrailingColor: leadColor,
    );
  }

  String _formatRemaining(Duration d) {
    if (d == Duration.zero) return 'Ended';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }
}
