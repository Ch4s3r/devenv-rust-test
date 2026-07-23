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

`.github/workflows/build.yml` builds and tests the binary in a matrix across:

- `x86_64-linux` on `ubuntu-latest`
- `aarch64-darwin` on `macos-14`

Each job follows the [devenv GitHub Actions integration](https://devenv.sh/integrations/github-actions/)
pattern (`cachix/install-nix-action`, `cachix/cachix-action` with the `devenv` cache,
`nix profile add nixpkgs#devenv`, `devenv test`), which runs `cargo nextest run`.
Since this project uses devenv via [flake-parts](https://devenv.sh/guides/using-with-flake-parts/),
whose flake-integration CLI only exposes `tasks`/`test`/`up`/`version` (no `devenv shell`),
the binary itself is built with `nix build .#packages.<system>.default` and uploaded as a
workflow artifact.
