/// Reusable dialog widgets
///
/// Provides generic, styled dialogs for use across the app.
/// These widgets are independent of the effect system and can be
/// used directly or via [ShowDialogEffect].
library;

import 'package:flutter/material.dart';
import 'package:health_duel/core/bloc/effect/dialog/config/dialog_action_config.dart';
import 'package:health_duel/core/theme/theme.dart';

part 'fullscreen_dialog.dart';
part 'icon_dialog.dart';


/// Helper functions for showing dialogs
class AppDialogs {
  AppDialogs._();

  /// Show a fullscreen dialog
  ///
  /// Returns the [DialogAction] selected by the user, or null if dismissed.
  static Future<DialogAction?> showFullscreen({
    required BuildContext context,
    required String title,
    required String message,
    required List<DialogActionConfig> actions,
    DialogIcon? icon,
    bool isDismissible = false,
  }) {
    return showDialog<DialogAction>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (ctx) => Dialog.fullscreen(
        child: _FullscreenDialogContent(
          icon: icon,
          title: title,
          message: message,
          actions: actions,
        ),
      ),
    );
  }

  /// Show a standard alert dialog
  ///
  /// Returns the [DialogAction] selected by the user, or null if dismissed.
  static Future<DialogAction?> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    required List<DialogActionConfig> actions,
    DialogIcon? icon,
    bool isDismissible = true,
  }) {
    final theme = Theme.of(context);

    return showDialog<DialogAction>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (ctx) => AlertDialog(
        icon: icon != null ? DialogIconWidget(icon: icon) : null,
        title: Text(title),
        content: Text(message),
        actions: actions
            .map(
              (config) => TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: config.action == DialogAction.destructive
                    ? theme.colorScheme.error
                    : null,
                ),
                onPressed: () {
                  // Call config's onPressed callback first (if any)
                  config.onPressed?.call();
                  Navigator.of(ctx).pop(config.action);
                },
                child: Text(config.effectiveLabel),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Show a confirmation dialog with OK/Cancel buttons
  ///
  /// Returns true if confirmed, false if cancelled.
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'OK',
    String cancelLabel = 'Cancel',
    DialogIcon? icon,
    bool isDestructive = false,
  }) async {
    final result = await showAlert(
      context: context,
      title: title,
      message: message,
      icon: icon,
      actions: [
        DialogActionConfig(
          action: DialogAction.cancel,
          label: cancelLabel,
        ),
        DialogActionConfig(
          action: isDestructive ? DialogAction.destructive : DialogAction.confirm,
          label: confirmLabel,
          isPrimary: true,
        ),
      ],
    );

    return result == DialogAction.confirm || result == DialogAction.destructive;
  }
}
