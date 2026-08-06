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

`.github/workflows/build.yml` runs a `ubuntu-latest` + `macos-latest` matrix. Each job:

- runs the test suite via `nix build .#tests -L`
- builds the release artifact via `nix build .#default`
- on `macos-latest`, code-signs the release binary (see below)
- uploads the binary as a workflow artifact (`devenv-rust-test-<os>`)

Steps run inside `nix develop --impure -c bash -- {0}` (set via `defaults.run.shell`), so
devenv scripts are available by name.

### macOS code signing

The `macos-latest` job signs the release binary using
[`rcodesign`](https://github.com/indygreg/apple-platform-rs) (via the `sign` devenv script),
a pure-Rust implementation of Apple code signing.

The CI step is a one-liner (`run: sign`); the `sign` script itself handles the logic: it
copies `result/bin/devenv-rust-test` to a writable location (the Nix store output is
read-only), then if `MACOS_CODESIGN_P12_BASE64` and `MACOS_CODESIGN_P12_PASSWORD` are set,
decodes the base64 secret via process substitution (`<(base64 -d <<< ...)`) straight into
`rcodesign`, so the `.p12` certificate never touches disk. Otherwise it falls
back to ad-hoc signing (no identity), which is enough to satisfy macOS Gatekeeper for
local/unnotarized use but not for distribution.
