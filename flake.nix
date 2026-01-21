{
  description = "GTSAM: Georgia Tech Smoothing and Mapping library";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        };
        python = pkgs.python314;
      in
      {
        # Packages
        packages = {
          default = pkgs.gtsam;
          gtsam = pkgs.gtsam;
          gtsam-python = pkgs.python314Packages.gtsam;
        };

        # Development shell for working on GTSAM itself
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.ccache
            pkgs.cmake
            pkgs.cmakeWithGui
            pkgs.boost
            pkgs.tbb
            pkgs.mkl
            pkgs.eigen
            pkgs.lldb
            (python.withPackages (ps: [
              ps.graphviz
              ps.jupyter
              ps.matplotlib
              ps.numpy
              ps.plotly
              ps.pybind11-stubgen
              ps.pyparsing
              ps.pytest
            ]))
          ];
          shellHook = ''
            export PYTHONPATH="$PWD/build/python''${PYTHONPATH:+:$PYTHONPATH}"
          '';
        };
      }
    )
    // {
      # Overlay for use in other flakes
      overlays.default = final: prev: {
        gtsam = final.callPackage ./nix/default.nix {
          src = self;
        };

        # Add gtsam to each Python package set
        python3Packages = prev.python3Packages.overrideScope (
          pyFinal: pyPrev: {
            gtsam = final.callPackage ./nix/python.nix {
              inherit (pyFinal) python3 toPythonModule;
              gtsam = final.gtsam;
            };
          }
        );

        python314Packages = prev.python314Packages.overrideScope (
          pyFinal: pyPrev: {
            gtsam = final.callPackage ./nix/python.nix {
              python3 = final.python314;
              inherit (pyFinal) toPythonModule;
              gtsam = final.gtsam.override { python3 = final.python314; };
            };
          }
        );
      };
    };
}
