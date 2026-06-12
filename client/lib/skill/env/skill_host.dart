import 'package:fx_dio/fx_dio.dart';

class SkillHost extends Host {
  const SkillHost();

  @override
  Map<HostEnv, String> get value => {
    HostEnv.release: 'toly1994.com',
    HostEnv.dev: '127.0.0.1',
  };

  @override
  HostConfig get config => const HostConfig(
    scheme: 'http',
    port: 3000,
    apiNest: '/api',
  );

  @override
  HostEnv get env => HostEnv.dev;
}

mixin SkillHostMixin {
  Host get host => FxDio()<SkillHost>();
}
