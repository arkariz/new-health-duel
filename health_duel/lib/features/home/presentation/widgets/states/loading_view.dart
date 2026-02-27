import 'package:flutter/material.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = context.horizontalPadding;

    return Shimmer(
      child: SkeletonBuilder(
        padding: EdgeInsets.fromLTRB(hPad, AppSpacing.sm, hPad, AppSpacing.xl),
      )
          // 1. Greeting header: name left, notif bell right
          .addWidget(
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonText(width: 72, height: 11),
                    SizedBox(height: 5),
                    SkeletonText(width: 140, height: 18),
                  ],
                ),
                SkeletonBox(width: 36, height: 36, borderRadius: 12),
              ],
            ),
          )
          .addGap(AppSpacing.md)

          // 2. Steps hero card
          .addWidget(const SkeletonBox(height: 130, borderRadius: 24))
          .addGap(AppSpacing.lg)

          // 3. Active Duels section header
          .addWidget(
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonText(width: 110, height: 15),
                SkeletonText(width: 52, height: 12),
              ],
            ),
          )
          .addGap(AppSpacing.sm)

          // 4. Live duel card
          .addWidget(const SkeletonBox(height: 148, borderRadius: 20))
          .addGap(AppSpacing.lg)

          // 5. Quick Actions section header
          .addText(width: 110, height: 15)
          .addGap(AppSpacing.sm)

          // 6. 2×2 Quick Actions grid
          .addRow(
            [
              const Expanded(child: SkeletonBox(height: 68, borderRadius: 16)),
              const Expanded(child: SkeletonBox(height: 68, borderRadius: 16)),
            ],
            spacing: AppSpacing.sm,
          )
          .addGap(AppSpacing.sm)
          .addRow(
            [
              const Expanded(child: SkeletonBox(height: 68, borderRadius: 16)),
              const Expanded(child: SkeletonBox(height: 68, borderRadius: 16)),
            ],
            spacing: AppSpacing.sm,
          )

          .buildScrollable(),
    );
  }
}