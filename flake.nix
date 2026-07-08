{
  inputs = {
    # I'm used to Arch Linux
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Hardware support flake for Snapdragon X Elite
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
      # So that `nix fmt` can work
      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt;

      # Lenovo Yoga Slim 7x (Snapdragon X Elite) configuration
      nixosConfigurations.yoga-slim-7x = nixpkgs.lib.nixosSystem {
        modules = [
          # Hardware support module. Does a lot of work.
          x1e-nixos-config.nixosModules.x1e

          # Inline NixOS configuration settings specific to the Yoga Slim 7x
          {
            networking.hostName = "yoga-slim-7x";
            hardware.lenovo-yoga-slim7x.enable = true;
            nixpkgs.hostPlatform.system = "aarch64-linux";

            # This can probably be moved to configuration.nix. I like flakes.
            nix = {
              channel.enable = false;
              settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
            };
          }

          # My system configuration (should be hardware-agnostic)
          ./configuration.nix

          # Home Manager: sets up my desktop environment, apps, etc.
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.user = import ./home.nix;
          }
        ];
      };
    };
}
