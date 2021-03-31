{
  description = "Nix: Coding development environment";
  inputs = {
    haskell-flake-env = {
      url = "path:./haskell";
    };
    python-flake-env = {
      url = "path:./python";
    };
    rust-flake-env = {
      url = "path:./rust";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils, haskell-flake-env, python-flake-env, rust-flake-env }:
    {
      packages = { } // (nixpkgs.lib.recursiveUpdate haskell-flake-env.packages
        (nixpkgs.lib.recursiveUpdate
          rust-flake-env.packages
          python-flake-env.packages
        ));
    };
}