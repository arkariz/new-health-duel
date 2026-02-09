/// User feedback effects
library;

import 'package:health_duel/core/bloc/bloc.dart';

abstract class FeedbackEffect extends UiEffect implements AutoDismissEffect {
  FeedbackEffect();
}

