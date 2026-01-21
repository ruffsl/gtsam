# Building GTSAM with Nix

This guide documents how to build GTSAM with Python bindings using Nix flakes.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- (Optional) [direnv](https://direnv.net/) with [nix-direnv](https://github.com/nix-community/nix-direnv) for automatic environment activation

## Quick Start

### Using direnv (recommended)

If you have direnv configured, the development environment will activate automatically when you enter the repository:

```bash
cd gtsam
direnv allow  # first time only
```

### Using nix develop

Alternatively, enter the development shell manually:

```bash
nix develop
```

## Building

Once in the development environment:

```bash
mkdir build && cd build
cmake -DGTSAM_BUILD_PYTHON=ON ..
make -j$(nproc)
```

### Build Options

Common CMake options for Python development:

| Option | Description | Default |
|--------|-------------|---------|
| `GTSAM_BUILD_PYTHON` | Build Python bindings | OFF |
| `GTSAM_BUILD_TESTS` | Build unit tests | ON |
| `GTSAM_BUILD_UNSTABLE` | Build unstable modules | ON |
| `GTSAM_UNSTABLE_BUILD_PYTHON` | Python bindings for unstable | ON |

Example with custom options:

```bash
cmake -DGTSAM_BUILD_PYTHON=ON \
      -DGTSAM_BUILD_TESTS=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      ..
```

## Using the Python Module

The flake's `shellHook` automatically adds `build/python` to `PYTHONPATH`. After building, you can use GTSAM directly:

```bash
python -c "import gtsam; print(gtsam.__file__)"
```

Or run the Python tests:

```bash
make python-test
```

## Included Dependencies

The Nix flake provides:

- **Build tools**: cmake, ccache
- **Libraries**: boost, tbb, eigen, mkl
- **Python packages**: numpy, matplotlib, pyparsing, jupyter, pybind11-stubgen, graphviz

## Notes

- Intel MKL requires `allowUnfree = true` in the Nix configuration (already set in the flake)
- ccache is enabled by default (`GTSAM_BUILD_WITH_CCACHE=ON`) to speed up rebuilds
- When changing the flake, delete `build/CMakeCache.txt` and reconfigure to pick up new paths
