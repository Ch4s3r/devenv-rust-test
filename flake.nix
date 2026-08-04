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
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
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
        let
          cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
          crateName = cargoToml.package.name;
        in
        {
          packages.default = config.devenv.shells.default.languages.rust.import ./. { };

          devenv.shells.default = {
            name = crateName;

            imports = [
              # This is just like the imports in devenv.nix.
              # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
              # ./devenv-foo.nix
            ];

            languages.rust = {
              enable = true;
              toolchainFile = ./rust-toolchain.toml;
            };

            # https://devenv.sh/reference/options/
            packages = [ pkgs.cargo-nextest pkgs.cargo-zigbuild pkgs.zig pkgs.file pkgs.rcodesign ];

            scripts.build.exec = ''
              cargo build --release
            '';

            scripts.build-aarch64-darwin.exec = ''
              cargo zigbuild --release --target aarch64-apple-darwin
            '';

            scripts.sign-aarch64-darwin.exec = ''
              set -euo pipefail
              binary=target/aarch64-apple-darwin/release/${crateName}
              p12="''${MACOS_CODESIGN_P12_PATH:-/tmp/codesign.p12}"

              if [ -f "$p12" ]; then
                rcodesign sign --p12-file "$p12" --p12-password "$MACOS_CODESIGN_P12_PASSWORD" "$binary"
              else
                echo "no codesigning certificate found at $p12, falling back to ad-hoc signing"
                rcodesign sign "$binary"
              fi

              rcodesign print-signature-info "$binary"
            '';

            scripts.sign.exec = ''
              set -euo pipefail
              binary=target/release/${crateName}
              p12="''${MACOS_CODESIGN_P12_PATH:-/tmp/codesign.p12}"

              if [ -f "$p12" ]; then
                rcodesign sign --p12-file "$p12" --p12-password "$MACOS_CODESIGN_P12_PASSWORD" "$binary"
              else
                echo "no codesigning certificate found at $p12, falling back to ad-hoc signing"
                rcodesign sign "$binary"
              fi

              rcodesign print-signature-info "$binary"
            '';

            scripts.tests.exec = ''
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
