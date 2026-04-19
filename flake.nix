{
  description = "Declarative task manager implemented in lua.";

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
      packages.${system}.default = pkgs.writeShellApplication {
        name = "todo";

        runtimeInputs = [
          (pkgs.lua.withPackages (
            ps: with ps; [
              dkjson
              luafilesystem
              penlight
            ]
          ))
          pkgs.viddy
          pkgs.gum
			 pkgs.neovim
        ];

        text = ''
          lua ${self}/src/main.lua "$@"
        '';

        meta = {
          description = "todo CLI wrapper";
          mainProgram = "Taskmanger";
        };
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/todo";
        meta = {
          description = "Taskmanger";
        }; # TODO: add a license and stuff
      };
    };
}
