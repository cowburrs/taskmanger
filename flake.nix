{
  description = "todo CLI wrapper";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.writeShellScriptBin "todo" ''
        ${pkgs.lua}/bin/lua ${self}/src/main.lua "$@"
      '';

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/todo";
        description = "todo CLI wrapper";
      };
    };
}
