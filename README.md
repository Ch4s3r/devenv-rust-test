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

### GitHub Actions cache proof (`cache-test.yml`)

`.github/workflows/cache-test.yml` proves `actions/cache` works for a large (1GB)
artifact: on cache miss it generates a 1GB `dummy.bin` (`dd if=/dev/urandom`) and saves
it under key `dummy-1gb-file-v1`; on cache hit it skips generation and restores the file
instead. Trigger manually via `gh workflow run cache-test.yml` or on push to the workflow
file itself.

Measured on `ubuntu-latest` runners (run IDs
[31492931341](https://github.com/Ch4s3r/devenv-rust-test/actions/runs/31492931341) miss,
[31492978053](https://github.com/Ch4s3r/devenv-rust-test/actions/runs/31492978053) hit):

| Run | Cache | `Restore cached dummy file` step duration |
| --- | --- | --- |
| 1st | miss | 1s (nothing to restore, falls through to generate) |
| 2nd | hit | 6s (restores full 1GB from cache) |

So restoring a cached 1GB file back onto the runner took ~6s, versus ~3s to generate it
fresh with `dd` — the cache mainly pays off when the artifact is expensive to
regenerate, not just large.
