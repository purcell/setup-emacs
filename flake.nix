{
  description = "Setup Emacs Action";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    {
      devShell = builtins.mapAttrs (
        system: pkgs:
        pkgs.mkShell {
          buildInputs = with pkgs; [ pkgs.shellcheck ];
        }
      ) nixpkgs.legacyPackages;
    };
}
