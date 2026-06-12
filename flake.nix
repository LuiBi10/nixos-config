{
  description = "NixOS config with Zen Browser";

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
      targetSystem = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [
          # 1. Configuración global de Nixpkgs del sistema
          {
            nixpkgs.hostPlatform = targetSystem;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.permittedInsecurePackages = [
              "electron-39.8.10"
              "qtwebengine-5.15.19"
            ];
          }

          # 2. Configuración principal de NixOS
          ./configuration.nix

          # 3. Configuración de Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luibi = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }

          # 4. Instalación de Zen Browser
          ({ pkgs, ... }: {
            environment.systemPackages = [
              zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight
            ];
          })
        ];
      };
    };
}

