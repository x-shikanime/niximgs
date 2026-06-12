{
  inputs = {
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devlib = {
      url = "github:shikanime-studio/devlib";
      inputs = {
        devenv.follows = "devenv";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cachix.cachix.org"
      "https://devenv.cachix.org"
      "https://shikanime.cachix.org"
      "https://shikanime-studio.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "shikanime.cachix.org-1:OrpjVTH6RzYf2R97IqcTWdLRejF6+XbpFNNZJxKG8Ts="
      "shikanime-studio.cachix.org-1:KxV6aDFU81wzoR9u6pF1uq0dQbUuKbodOSP8/EJHXO0="
    ];
  };

  outputs =
    inputs@{
      devenv,
      devlib,
      flake-parts,
      git-hooks,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devenv.flakeModule
        devlib.flakeModule
        git-hooks.flakeModule
        treefmt-nix.flakeModule
      ];
      perSystem =
        {
          self',
          lib,
          pkgs,
          ...
        }:
        with lib;
        {
          devenv.shells.default = {
            imports = [
              inputs.devlib.devenvModules.git
              inputs.devlib.devenvModules.nix
              inputs.devlib.devenvModules.opentofu
              inputs.devlib.devenvModules.shell
              inputs.devlib.devenvModules.shikanime-studio
            ];
            github = {
              settings.workflows = {
                integration = {
                  jobs.skaffold = {
                    needs = [ "nix" ];
                    secrets.CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                  };
                  on.workflow_call.secrets.CACHIX_AUTH_TOKEN.required = mkDefault true;
                };

                release = {
                  jobs.skaffold = {
                    needs = [ "nix" ];
                    secrets.CACHIX_AUTH_TOKEN = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                  };
                  on.workflow_call.secrets.CACHIX_AUTH_TOKEN.required = mkDefault true;
                };

                skaffold.on.workflow_call.secrets.CACHIX_AUTH_TOKEN.required = mkDefault true;

                wakabox = {
                  name = "Wakabox";
                  on.schedule = [
                    { cron = "0 0 * * *"; }
                  ];
                  jobs.wakabox = {
                    runs-on = "ubuntu-latest";
                    steps = [
                      {
                        uses = "matchai/waka-box@v5.0.0";
                        env = {
                          GH_TOKEN = "\${{ secrets.WAKABOX_GITHUB_TOKEN }}";
                          GIST_ID = "\${{ vars.WAKABOX_GITHUB_GIST_ID }}";
                          WAKATIME_API_KEY = "\${{ secrets.WAKATIME_API_KEY }}";
                        };
                      }
                    ];
                  };
                  permissions.contents = "read";
                };
              };

              workflows.skaffold = {
                enable = true;
                settings.setup-nix = {
                  cachix-auth-token = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
                  extra-platforms = "arm64";
                };
              };
            };

            packages = with pkgs; [
              skaffold
            ];
          };
          packages = {
            base = pkgs.callPackage ./pkgs/base { };
            jellyfin = pkgs.callPackage ./pkgs/jellyfin { inherit (self'.packages) base; };
            mlflow = pkgs.callPackage ./pkgs/mlflow { inherit (self'.packages) base; };
            postgresql = pkgs.callPackage ./pkgs/postgresql { inherit (self'.packages) base; };
            radarr = pkgs.callPackage ./pkgs/radarr { inherit (self'.packages) base; };
            sonarr = pkgs.callPackage ./pkgs/sonarr { inherit (self'.packages) base; };
            syncthing = pkgs.callPackage ./pkgs/syncthing { inherit (self'.packages) base; };
            vaultwarden = pkgs.callPackage ./pkgs/vaultwarden { inherit (self'.packages) base; };
            whisparr = pkgs.callPackage ./pkgs/whisparr { inherit (self'.packages) base; };
          };
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
