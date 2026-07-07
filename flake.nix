{
  inputs = {
    # Unstable nixpkgs, required for now.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # This repository.
    x1e-nixos-config.url = "github:kuruczgy/x1e-nixos-config";
    x1e-nixos-config.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      x1e-nixos-config,
    }:
    {
      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;

      # Change "system" to your chosen hostname here:
      nixosConfigurations.system = nixpkgs.lib.nixosSystem {
        modules = [
          x1e-nixos-config.nixosModules.x1e

          # Inline NixOS configuration settings
          {
            networking.hostName = "system";
            hardware.lenovo-yoga-slim7x.enable = true;
            nixpkgs.hostPlatform.system = "aarch64-linux";

            # Uncomment this to allow unfree packages.
            # nixpkgs.config.allowUnfree = true;

            nix = {
              channel.enable = false;
              settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
            };
          }

          ./configuration.nix

          # 1. Include the Home Manager NixOS module
          home-manager.nixosModules.home-manager

          # 2. Configure Home Manager settings as an attribute set module
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.user = import ./home.nix;
          }
        ];
      };
    };
}
