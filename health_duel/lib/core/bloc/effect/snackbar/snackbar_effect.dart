import 'package:health_duel/core/bloc/bloc.dart';

enum FeedbackSeverity { info, success, warning, error }

final class ShowSnackBarEffect extends FeedbackEffect {
  final String message;
  final FeedbackSeverity severity;
  final String? actionLabel;
  final String? actionIntentId;

  @override
  final Duration autoDismissDuration;

  ShowSnackBarEffect({
    required this.message,
    this.severity = FeedbackSeverity.info,
    this.actionLabel,
    this.actionIntentId,
    this.autoDismissDuration = const Duration(seconds: 4),
  }) : assert(
    actionLabel == null || actionIntentId != null,
    'actionIntentId required when actionLabel provided',
  );

  @override
  List<Object?> get props => [
    ...super.props, // Include timestamp from UiEffect
    message,
    severity,
    actionLabel,
    actionIntentId,
    autoDismissDuration,
  ];
}