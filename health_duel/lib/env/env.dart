import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.envs/dev.env', name: 'EnvDev', obfuscate: true)
@Envied(path: '.envs/prod.env', name: 'EnvProd', obfuscate: true)
final class Env {
  static const String flavor = String.fromEnvironment('FLAVOR');

  factory Env() => _instance;

  static final Env _instance = switch (flavor) {
    'dev' => _EnvDev(),
    'prod' => _EnvProd(),
    _ => _EnvDev(),
  };

  @EnviedField(varName: 'APP_NAME')
  final String appName = _instance.appName;
  @EnviedField(varName: 'BASE_URL')
  final String baseUrl = _instance.baseUrl;
  @EnviedField(varName: 'AES_KEY_PLATFORM')
  final String aesKeyPlatform = _instance.aesKeyPlatform;
  @EnviedField(varName: 'IS_DEBUG_MODE')
  final String isDebugMode = _instance.isDebugMode;
}
