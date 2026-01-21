{
  description = "GTSAM python development environment";

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
          config = { allowUnfree = true; }; 
        };
        python = pkgs.python314.withPackages (ps: [
          ps.graphviz
          ps.jupyter
          ps.matplotlib
          ps.numpy
          ps.plotly
          ps.pybind11-stubgen
          ps.pyparsing
          ps.pytest
        ]);
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            ccache
            cmake
            cmakeWithGui
            boost
            tbb
            mkl
            eigen
            lldb
            python
          ];
          shellHook = ''
            export PYTHONPATH="$PWD/build/python''${PYTHONPATH:+:$PYTHONPATH}"
          '';
        };
      }
    );
}
