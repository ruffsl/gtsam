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
          ps.graphviz # not required, but used for example scripts
          ps.jupyter # not required, but used for example scripts
          ps.matplotlib # not required, but used for example scripts
          ps.numpy # not required, but used for example scripts
          ps.plotly # not required, but used for example scripts
          ps.pybind11-stubgen # required for build, e.g., python bindings
          ps.pyparsing # required for build, e.g., python bindings
          ps.pytest # required for testing, e.g., make python-test
        ]);
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            ccache # not required, but helpful for faster development
            cmake # required for build
            cmakeWithGui # not required, but helpful ergonomic development
            boost # optional build dependency
            tbb # optional build dependency
            mkl # optional build dependency
            eigen # optional build dependency
            lldb # not required, but helpful for debugging development
            python # required for python bindings
          ];
          # Environment variable to find python bindings for development
          shellHook = ''
            export PYTHONPATH="$PWD/build/python''${PYTHONPATH:+:$PYTHONPATH}"
          '';
        };
      }
    );
}
