{
  description = "Declarative task manager implemented in lua.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.writeShellApplication {
        name = "todo";

        runtimeInputs = with pkgs; [
          (lua.withPackages (
            ps: with ps; [
              dkjson
              luafilesystem
              penlight
            ]
          ))
          viddy
          gum
          neovim
          prettier
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
			 homepage = "https://github.com/cowburrs/taskmanger";
          description = "A declarative task manager with lua configuration";
          license = nixpkgs.lib.licenses.mit;
			 platforms = nixpkgs.lib.platforms.linux;
			 mainProgram = "Taskmanger";
        }; 
      };
    };
}
