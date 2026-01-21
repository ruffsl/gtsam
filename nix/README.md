# GTSAM Nix Support

This directory contains Nix packaging for GTSAM. The flake provides:

- **Packages**: Pre-built GTSAM C++ library and Python bindings
- **Overlay**: For integrating GTSAM into other Nix projects
- **Development shell**: For working on GTSAM itself

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- (Optional) [direnv](https://direnv.net/) with [nix-direnv](https://github.com/nix-community/nix-direnv) for automatic environment activation

## Quick Start

### Using GTSAM as a Package

Build and use the C++ library:

```bash
nix build github:borglab/gtsam#gtsam
```

Build with Python bindings:

```bash
nix build github:borglab/gtsam#gtsam-python
```

### Using GTSAM in Your Flake

Add GTSAM as an input and use the overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    gtsam.url = "github:borglab/gtsam";
  };

  outputs = { self, nixpkgs, gtsam }: {
    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;  # Required for MKL
        overlays = [ gtsam.overlays.default ];
      };
    in pkgs.mkShell {
      packages = [
        pkgs.gtsam                    # C++ library
        pkgs.python3Packages.gtsam    # Python bindings
      ];
    };
  };
}
```

## Development

For contributing to GTSAM itself, use the development shell:

### Using direnv (recommended)

```bash
cd gtsam
direnv allow  # first time only
```

### Using nix develop

```bash
nix develop
```

### Building from Source

Once in the development shell:

```bash
mkdir build && cd build
cmake -DGTSAM_BUILD_PYTHON=ON ..
make -j$(nproc)
```

The shell automatically sets `PYTHONPATH` to include `build/python`, so you can test immediately:

```bash
python -c "import gtsam; print(gtsam.__file__)"
make python-test
```

## Package Options

The GTSAM package supports these build options via `.override`:

| Option | Description | Default |
|--------|-------------|---------|
| `enableBoostFeatures` | Enable Boost-based features | `true` |
| `enableBoostSerialization` | Enable Boost serialization | `true` |
| `enableTBB` | Enable Intel TBB parallelization | `true` |
| `enableMKL` | Enable Intel MKL (requires `allowUnfree`) | `false` |
| `enablePython` | Build Python bindings | `false` |
| `enableUnstable` | Build gtsam_unstable module | `true` |
| `doCheck` | Run tests during build | `false` |

Example with custom options:

```nix
pkgs.gtsam.override {
  enableMKL = true;
  enableTBB = false;
  doCheck = true;
}
```

## Flake Outputs

| Output | Description |
|--------|-------------|
| `packages.*.gtsam` | C++ library |
| `packages.*.gtsam-python` | Python bindings (Python 3.14) |
| `overlays.default` | Overlay adding `gtsam` and `python3Packages.gtsam` |
| `devShells.*.default` | Development environment |

## Notes

- Intel MKL requires `config.allowUnfree = true` in your nixpkgs configuration
- The overlay extends `python3Packages` and `python314Packages` with GTSAM
- When modifying the flake during development, delete `build/CMakeCache.txt` and reconfigure
- ccache is available in the dev shell for faster rebuilds
