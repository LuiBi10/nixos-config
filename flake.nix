{
  description = "NixOS config with Zen Browser and JupyterLab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ nixpkgs, home-manager, zen-browser, ... }:
    let
      # Definimos el sistema como una variable local para usarla en el flake
      targetSystem = "x86_64-linux";
      pkgs = import nixpkgs {
        system = targetSystem;
        config.allowUnfree = true;
      };
      pythonWithPackages = import ./python-packages.nix { inherit pkgs; };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        # Eliminamos 'system = targetSystem;' de aquí, se define en los módulos abajo
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          # Establecemos la plataforma de forma moderna
          { nixpkgs.hostPlatform = targetSystem; }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luibi = import ./home.nix;
            # CORRECCIÓN: Quitamos 'system' de extraSpecialArgs
            home-manager.extraSpecialArgs = { inherit inputs; };
          }

          ({ pkgs, ... }: {
            environment.systemPackages = [
              zen-browser.packages.${pkgs.system}.twilight
            ];
          })
        ];
      };

      # Usamos targetSystem para el devShell
      devShells.${targetSystem}.jupyterlab =
        import ./dev-shell.nix { inherit pkgs pythonWithPackages; };
    };
}
