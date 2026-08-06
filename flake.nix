{
  description = "Description for the project";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    crate2nix.url = "github:nix-community/crate2nix";
    crate2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, devenv-root, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
        {
          packages.default = config.devenv.shells.default.languages.rust.import ./. { };

          apps.sign-aarch64-darwin = {
            type = "app";
            program = pkgs.lib.getExe (pkgs.writeShellApplication {
              name = "sign";
              runtimeInputs = [ pkgs.rcodesign ];
              text = ''
                binary=./devenv-rust-test
                cp --no-preserve=mode,ownership result/bin/devenv-rust-test "$binary"

                : "''${MACOS_CODESIGN_P12_BASE64:?MACOS_CODESIGN_P12_BASE64 must be set, ad-hoc signing not allowed}"
                : "''${MACOS_CODESIGN_P12_PASSWORD:?MACOS_CODESIGN_P12_PASSWORD must be set, ad-hoc signing not allowed}"

                rcodesign sign --p12-file <(base64 -d <<< "$MACOS_CODESIGN_P12_BASE64") --p12-password "$MACOS_CODESIGN_P12_PASSWORD" "$binary"
                rcodesign print-signature-info "$binary"
              '';
            });
          };

          devenv.shells.default = {
            imports = [
              # This is just like the imports in devenv.nix.
              # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
              # ./devenv-foo.nix
            ];

            languages.rust = {
              enable = true;
            };

            # https://devenv.sh/reference/options/
            packages = [ pkgs.cargo-nextest ];

            enterTest = ''
              cargo nextest run
            '';
          };

        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
