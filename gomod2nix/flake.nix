{
  description = "gomod2nix-develop";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/3a7674c896847d18e598fa5da23d7426cb9be3d2";
    gomod2nix = { url = "github:tweag/gomod2nix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , flake-utils
    , gomod2nix
    }:
    { }
    //
    (flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ]
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlay
            (import "${gomod2nix}/overlay.nix")
          ];
          config = { };
        };
      in
      rec {
        devShell = with pkgs; mkShell {
          buildInputs = [
            gomod2nix
          ];
          shellHook = ''
            ehco ${gomod2nix};
          '';
        };
        defaultPackage = pkgs.gomod2nix-example;
      }
      )
    ) //
    {
      overlay = final: prev: {
        gomod2nix-example = with final;
          (buildGoApplication {
            pname = "gomod2nix-example";
            version = "0.1";
            src = ./.;
            modules = ./gomod2nix.toml;
          });
      };
    };
}