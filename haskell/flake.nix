{
  description = "Haskell development environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    darwin-nixpkgs.url = "nixpkgs/7d71001b796340b219d1bfa8552c81995017544a";
    nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    easy-hls-nix = {
      url = "github:jkachmar/easy-hls-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    darwin-nixpkgs,
    flake-utils,
    flake-compat,
    easy-hls-nix,
  }:
    {}
    // (
      flake-utils.lib.eachSystem ["x86_64-linux" "x86_64-darwin"]
      (
        system: let
          pkgs =
            if system == "x86_64-darwin"
            then
              import darwin-nixpkgs
              {
                inherit system;
                overlays = [
                  self.overlay
                ];
                config = {};
              }
            else
              import nixpkgs {
                inherit system;
                overlays = [
                  self.overlay
                ];
                config = {};
              };
        in rec {
          #haskellPackages = pkgs.haskell.packages.ghc884;
          packages = {
            inherit
              (pkgs)
              easy-hls
              ;
          };

          devShell = with pkgs;
            mkShell {
              buildInputs = [
                easy-hls
                (haskellPackages.ghcWithPackages
                  (p:
                    with p; [
                      brittany #format
                      relude
                    ]))
              ];
            };
        }
      )
    )
    // {
      overlay = final: prev: {
        easy-hls =
          prev.callPackage easy-hls-nix
          (
            if prev.stdenv.isDarwin
            then {
              ghcVersions = ["8.10.3"];
            }
            else {ghcVersions = ["8.10.4"];}
          );
      };
    };
}
