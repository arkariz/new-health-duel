import 'package:flutter/widgets.dart';

/// Marker: Effect requires user response (e.g., dialog)
abstract interface class InteractiveEffect {
  String get intentId;
  void onShow(BuildContext context);
}