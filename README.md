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

The `aarch64-apple-darwin` binary is then code-signed using
[`rcodesign`](https://github.com/indygreg/apple-platform-rs) (via the
`sign-aarch64-darwin` devenv script), a pure-Rust, cross-platform implementation of
Apple code signing that works on the Linux `arc-runner-set` CI runner without needing
a real macOS host.

If the repository secrets `MACOS_CODESIGN_P12_BASE64` and `MACOS_CODESIGN_P12_PASSWORD`
are set, the workflow decodes the base64 secret into a `.p12` certificate and signs the
binary with it. Otherwise it falls back to ad-hoc signing (no identity), which is enough
to satisfy macOS Gatekeeper for local/unnotarized use but not for distribution.

Both binaries are uploaded as workflow artifacts (`devenv-rust-test-x86_64-linux` and
`devenv-rust-test-aarch64-darwin`).

Each step follows the [devenv GitHub Actions integration](https://devenv.sh/integrations/github-actions/)
pattern (`cachix/install-nix-action`, `cachix/cachix-action` with the `devenv` cache,
`nix profile add nixpkgs#devenv`, `nix develop --impure -c bash -- {0}` running the named
devenv script).

`.github/workflows/build.yml` (the previous `ubuntu-latest` + `macos-latest` matrix, building
natively on a real macOS runner) is disabled — its trigger is commented out — and kept only
for reference.
