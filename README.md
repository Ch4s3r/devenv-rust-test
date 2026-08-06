# devenv-rust-test

Rust binary built and developed with [devenv](https://devenv.sh) / Nix.

## Development

```
devenv shell
```

gives a shell with Rust (`languages.rust.enable`) and the built package available.

## Building locally

```
devenv build outputs.release
```

prints the built store path as JSON (`{"outputs.release": "/nix/store/..."}`); the binary
lives at `<store-path>/bin/devenv-rust-test`.

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

which runs `cargo nextest run`.

## CI

`.github/workflows/build.yml` runs a `ubuntu-latest` + `ubuntu-24.04-arm` + `macos-latest`
matrix (x86_64-linux, aarch64-linux, aarch64-darwin). Each job:

- builds the release artifact via `nix run nixpkgs#devenv -- build outputs.release`
  (no `devenv` install step), capturing the store path
- uploads the binary as a workflow artifact (`devenv-rust-test-<os>`)

Steps run inside `nix run nixpkgs#devenv -- shell bash -- -e {0}` (set via
`defaults.run.shell`), so the devenv shell environment is available without installing
`devenv` into the runner.

Steps run inside `nix develop --impure -c bash -- {0}` (set via `defaults.run.shell`), so
devenv scripts are available by name.
