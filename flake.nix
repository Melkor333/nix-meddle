{
  description = "Python env for shell commander";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      # my-python = pkgs.python3Full;
      # python-with-my-packages = my-python.withPackages (p: with p; [
      #   requests
      #   # other python packages you want
      #   # pygobject3
      #   # pkgs.networkmanager
      # ]);
    in {
    devShell = pkgs.mkShell {
      buildInputs = with pkgs; [
        gum
        rsync
      ];
      # shellHook = ''
      #   PYTHONPATH=${python-with-my-packages}/${python-with-my-packages.sitePackages}
      # '';
    };
  });
}

