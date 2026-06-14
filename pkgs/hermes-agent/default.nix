{ base, pkgs, hermes-agent-pkg }:

pkgs.dockerTools.streamLayeredImage {
  name = "hermes-agent";
  tag = "latest";
  fromImage = base;

  config = {
    Entrypoint = [
      "${hermes-agent-pkg}/bin/hermes"
    ];
    Env = [
      "HERMES_HOME=/data/.hermes"
    ];
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/x-shikanime/niximgs";
      "org.opencontainers.image.description" = "Hermes Agent by Nous Research — self-improving AI agent with persistent memory";
      "org.opencontainers.image.licenses" = "MIT";
    };
    User = "1000:1000";
    WorkingDir = "/data";
    Volumes = {
      "/data" = { };
    };
  };

  contents = [
    hermes-agent-pkg
  ];

  fakeRootCommands = ''
    mkdir -p ./data/.hermes
    chown 1000:1000 ./data/.hermes
  '';
}
