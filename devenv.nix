{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  languages.rust = {
    enable = true;
    toolchainFile = ./rust-toolchain.toml;
  };

  git-hooks.hooks = {
    rustfmt.enable = true;
    clippy.enable = true;
  };

  packages = [ pkgs.cargo-nextest ];

  enterTest = ''
    cargo nextest run
  '';

  outputs.release = config.languages.rust.import ./. { };
}
