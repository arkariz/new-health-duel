import 'package:get_it/get_it.dart';
import 'package:health_duel/features/auth/auth.dart';

SignInWithEmail get signInWithEmail => GetIt.instance<SignInWithEmail>();
SignInWithGoogle get signInWithGoogle => GetIt.instance<SignInWithGoogle>();
SignInWithApple get signInWithApple => GetIt.instance<SignInWithApple>();
RegisterWithEmail get registerWithEmail => GetIt.instance<RegisterWithEmail>();

// NOTE: GetCurrentUser and SignOut are global use cases from session module
// Access via: GetIt.instance<GetCurrentUser>() from 'package:health_duel/data/domain/domain.dart'