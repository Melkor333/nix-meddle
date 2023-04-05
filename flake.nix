{
  description = "Meddle with files in the nix store without breaking your system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = rec {
        nix-meddle = with import nixpkgs { system = system; };
        stdenv.mkDerivation {
        name = "nix-meddle";
        phases = "installPhase";
        source = self;
        installPhase = ''
          mkdir -p $out/bin
          cp $source/nix-meddle $out/bin/nix-meddle
          # Hack in the path to binaries
          sed -i 's|#!/usr/bin/env osh|#!${pkgs.bash}/bin/bash|' $out/bin/nix-meddle
          sed -i 's|gum |${pkgs.gum}/bin/gum |g' $out/bin/nix-meddle
          sed -i 's|rsync |${pkgs.rsync}/bin/rsync |g' $out/bin/nix-meddle
          sed -i 's|"mount"|"${pkgs.util-linux}/bin/mount"|g' $out/bin/nix-meddle
          '';
        };
        default = nix-meddle;
      };
      devShells.default = pkgs.mkShell {
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

