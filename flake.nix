{
  description = "Setup Emacs Action";

  inputs =
    {
      nixpkgs.url = "nixpkgs/nixpkgs-unstable";
      flake-utils.url = "github:numtide/flake-utils";
    };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [nodejs-16_x];
          shellHook = ''
            PATH="$PATH:$(pwd)/node_modules/.bin"
          '';
        };
      }
    );
}
