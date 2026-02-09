import 'dart:ui';

enum DialogAction { confirm, cancel, destructive, neutral }
enum DialogIcon { info, success, warning, error, question }

/// Dialog action button configuration
///
/// [onPressed] is optional - if null, dialog will just pop with the [action] value.
/// If provided, it will be called AND dialog will still pop.
class DialogActionConfig {
  final DialogAction action;
  final String? label;
  final bool isPrimary;
  
  /// Optional callback when this action is pressed.
  /// Called before Navigator.pop().
  /// Note: Excluded from equality comparison.
  final VoidCallback? onPressed;

  const DialogActionConfig({
    required this.action,
    this.label,
    this.isPrimary = false,
    this.onPressed,
  });

  String get defaultLabel => switch (action) {
    DialogAction.confirm => 'OK',
    DialogAction.cancel => 'Cancel',
    DialogAction.destructive => 'Delete',
    DialogAction.neutral => 'Skip',
  };

  String get effectiveLabel => label ?? defaultLabel;
}