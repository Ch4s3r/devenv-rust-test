# devenv-rust-test

Rust binary built and developed with [devenv](https://devenv.sh) / Nix flakes.

## Development

```
nix develop
```

gives a shell with Rust (`languages.rust.enable`) and the built package available.

## Building locally

```
nix build .#default
./result/bin/devenv-rust-test
```

The package version is derived from `Cargo.toml` plus the current git commit hash
(`<cargo-version>+<git-short-rev>`).

## Testing

```
cargo test
```

or, inside the devenv shell, via [cargo-nextest](https://nexte.st):

```
devenv test
```

which runs `cargo nextest run`. `nix build`/`buildRustPackage` also runs the test
suite as part of its check phase.

## CI

`.github/workflows/cross-build.yml` runs on a single `ubuntu-latest` runner and:

- runs `cargo nextest run` (via the `tests` devenv script)
- builds the native `x86_64-linux` release binary (via the `build` devenv script)
- cross-compiles an `aarch64-apple-darwin` release binary using
  [`cargo-zigbuild`](https://github.com/rust-cross/cargo-zigbuild) (via the
  `build-aarch64-darwin` devenv script), since Nix's own cross-compilation does not support
  building for Darwin from a Linux build platform

Both binaries are uploaded as workflow artifacts (`devenv-rust-test-x86_64-linux` and
`devenv-rust-test-aarch64-darwin`).

Each step follows the [devenv GitHub Actions integration](https://devenv.sh/integrations/github-actions/)
pattern (`cachix/install-nix-action`, `cachix/cachix-action` with the `devenv` cache,
`nix profile add nixpkgs#devenv`, `nix develop --impure -c bash -- {0}` running the named
devenv script).

`.github/workflows/build.yml` (the previous `ubuntu-latest` + `macos-latest` matrix, building
natively on a real macOS runner) is disabled — its trigger is commented out — and kept only
for reference.
