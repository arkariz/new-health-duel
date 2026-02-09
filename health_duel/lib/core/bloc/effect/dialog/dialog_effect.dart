/// Dialog-related effects
library;

import 'package:flutter/widgets.dart';
import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/core/presentation/widgets/dialog/dialog.dart';

/// Show dialog with intent-based actions (no callbacks)
final class ShowDialogEffect extends UiEffect implements InteractiveEffect {
  @override
  final String intentId;

  final String title;
  final String message;
  final List<DialogActionConfig> actions;
  final bool isDismissible;
  final bool isFullScreen;
  final DialogIcon? icon;

  ShowDialogEffect({
    required this.intentId,
    required this.title,
    required this.message,
    required this.actions,
    this.isDismissible = true,
    this.isFullScreen = false,
    this.icon,
  });

  factory ShowDialogEffect.fullScreen({
    required String intentId,
    required String title,
    required String message,
    required List<DialogActionConfig> actions,
  }) {
    return ShowDialogEffect(
      intentId: intentId,
      title: title,
      message: message,
      actions: actions,
      isDismissible: false,
      isFullScreen: true,
    );
  }

  factory ShowDialogEffect.simple({
    required String intentId,
    required String title,
    required String message,
    required List<DialogActionConfig> actions,
    DialogIcon? icon,
    bool isDismissible = true,
  }) {
    return ShowDialogEffect(
      intentId: intentId,
      title: title,
      message: message,
      actions: actions,
      isDismissible: isDismissible,
      isFullScreen: false,
      icon: icon,
    );
  }

  @override
  void onShow(BuildContext context) {
    if (isFullScreen) {
      AppDialogs.showFullscreen(
        context: context,
        title: title,
        message: message,
        actions: actions,
        icon: icon,
        isDismissible: isDismissible,
      );
    } else {
      AppDialogs.showAlert(
        context: context,
        title: title,
        message: message,
        actions: actions,
        icon: icon,
        isDismissible: isDismissible,
      );
    }
  }

  @override
  List<Object?> get props => [
    ...super.props, // Include timestamp from UiEffect
    intentId,
    title,
    message,
    actions.map((a) => a.action).toList(),
    isDismissible,
    isFullScreen,
    icon,
  ];
}
