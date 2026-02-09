import 'package:health_duel/core/config/app_config.dart';

class FlavorUtil {
  static Environment getFlavorFromEnv() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    switch (flavor.toLowerCase()) {
      case 'prod':
        return Environment.prod;
      case 'dev':
      default:
        return Environment.dev;
    }
  }
}
