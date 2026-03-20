{
  description = "OmniSearch (C metasearch engine) packaged for Nix";

  inputs = {
    # Using my own mirror. But pls follow your nixpkgs
    nixpkgs.url = "git+https://git.alovely.space/Mirrors/nixpkgs.git?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systems = ["x86_64-linux"];

    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (
        system:
          f (import nixpkgs {inherit system;})
      );
  in {
    # i have not figured yet out how to do it. But for x86_64 it works
    packages = forAllSystems (pkgs: let
      # Beaker library it is the dependency for Omnisearch and doenst need to be installed the module does it on its own
      beaker = pkgs.stdenv.mkDerivation {
        pname = "beaker";
        version = "git";

        src = pkgs.fetchgit {
          url = "https://git.alovely.space/Mirrors/beaker";
          rev = "38aa54bb91597bd15ecd1dca1da6194c80249039";
          sha256 = "sha256-K97/aeTrR5oGnIKdRhcC2xhqBDoVLDg4Eh4u/qZFGqE=";
        };

        nativeBuildInputs = [pkgs.pkg-config];
        buildPhase = "make";

        installPhase = ''
          mkdir -p $out/lib $out/include
          cp build/libbeaker.a $out/lib/
          cp build/libbeaker.so $out/lib/
          cp beaker.h $out/include/ || true
        '';

        meta = with pkgs.lib; {
          description = "Lightweight C library for building HTTP servers (beaker)";
          platforms = platforms.linux;
        };
      };

      # OmniSearch default install
      # I dont recommend installing it like that
      omnisearchFn = {
        templates ? ./omnisearchTest/templates,
        static ? ./omnisearchTest/static,
        config ? ./omnisearchTest/example-config.ini,
      }:
        pkgs.callPackage ./package-omnisearch.nix {inherit beaker templates static config;};
    in {
      # Exposing it both as function and package for the module
      omnisearch = omnisearchFn {};
      omnisearchWith = omnisearchFn;
    });

    # The module to actually set it up
    # idk why i did it both as default and omnisearch
    nixosModules = {
      default = ./module;
      omnisearch = ./module;
    };
  };
}
