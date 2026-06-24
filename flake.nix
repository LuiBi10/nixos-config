{
  description = "NixOS config with Zen Browser and JupyterLab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ nixpkgs, home-manager, zen-browser, ... }:
    let
      targetSystem = "x86_64-linux";
      pkgs = import nixpkgs {
        system = targetSystem;
        config.allowUnfree = true;
      };
      pythonWithPackages = import ./python-packages.nix { inherit pkgs; };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = targetSystem; }
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.luibi = { ... }: {
              imports = [
                (import ./home.nix)
                inputs.zen-browser.homeModules.twilight
              ];

              programs.zen-browser = {
                enable = true;
                policies = {
                  DisableAppUpdate = true;
                  DisableTelemetry = true;
                };
                profiles.default = {
                  sine.enable = true;
                };
              };
            };
          }
        ];
      };

      devShells.${targetSystem}.jupyterlab =
        import ./dev-shell.nix { inherit pkgs pythonWithPackages; };
    };
}
