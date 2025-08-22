{
  description = "A flake for overriding pre-commit with prefligit";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    flake-parts.url = "https://flakehub.com/f/hercules-ci/flake-parts/*";
    rust-overlay = {
      url = "https://flakehub.com/f/oxalica/rust-overlay/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:KaiSforza/devshell/attrs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "https://flakehub.com/f/cachix/git-hooks.nix/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } rec {
      systems = import inputs.systems;
      imports = [
        inputs.devshell.flakeModule
        inputs.git-hooks.flakeModule
      ];
      flake = {
        overlays = {
          default = (inputs.nixpkgs.lib.composeManyExtensions [
            (import inputs.rust-overlay)
            (f: p: {
              pre-commit' = p.pre-commit;
              pre-commit = (p.makeRustPlatform (let
                  rustToolchain =  p.rust-bin.stable.latest.minimal;
                in
                {
                  cargo = rustToolchain;
                  rustc = rustToolchain;
                })).buildRustPackage rec {
                pname = "prek";
                version = "0.1.2";
                src = p.fetchFromGitHub {
                  owner = "j178";
                  repo = pname;
                  rev = "v${version}";
                  hash = "sha256-iu+vcoT9VldTQKTVd+qJcGpPkFoLdhjaLiyNfcz3geU=";
                };
                cargoHash = "sha256-/C8IKjpmyv0Pv7ahRk/YmSAMuEJdhp9/bzKE+tiirDI=";
                # The tests fail here because the isolated env doesn't really play nice
                # with how the full test suite works.
                doCheck = false;
                # Adds a `pre-commit` command into the path from prefligit
                nativeBuildInputs = [ p.makeWrapper ];
                postInstall = ''
                  wrapProgram $out/bin/prek \
                    --suffix PATH : ${p.lib.makeBinPath [ p.gitMinimal ]}
                  ln -svr $out/bin/prek $out/bin/pre-commit
                '';
                meta.mainProgram = "pre-commit";
              };
            })
          ]);
        };
      };
      perSystem =
        {
          pkgs,
          config,
          inputs',
          ...
        }:
        {
          _module.args.pkgs = (inputs'.nixpkgs.legacyPackages.extend flake.overlays.default);
          packages = {
            default = pkgs.pre-commit;
          };
          pre-commit = {};
          devshells = {
            default = {
              name = "prefligit-shell";
              motd = "Template for using prefligit with git-hooks.nix";
              devshell.startup = {
                pre-commit.text = config.pre-commit.installationScript;
              };
            };
          };

          pre-commit = {
            check.enable = true;
            settings = {
              default_stages = [ "pre-push" ];
              hooks = {
                nixfmt-rfc-style.enable = true;
              };
            };
          };
        };
    };
}
