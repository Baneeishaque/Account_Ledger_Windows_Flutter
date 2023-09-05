import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(requireEnvFile: true)
abstract class Env {
  @EnviedField(varName: 'USER_NAME')
  static const String username = _Env.username;
  @EnviedField(varName: 'GITHUB_TOKEN')
  static const String gitHubAccessToken = _Env.gitHubAccessToken;
  @EnviedField(varName: 'GIST_ID')
  static const String gistId = _Env.gistId;
}
