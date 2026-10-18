{
  inputs = {
    # I'm used to Arch Linux
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Kernel 7.2.9 and above broke the keyboard.
    # So we need to have a nixpkgs input pinned to where kernel 7.2.8 was around
    # and use it for `boot.kernelPackages`.
    nixpkgs-kernel.url = "github:nixos/nixpkgs/c59305bab2065cfecc4944690d9eedbb56f3a9fa";

    # Hardware support flake for Snapdragon X Elite
    x1e-nixos-config = {
      url = "github:kuruczgy/x1e-nixos-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-kernel,
      home-manager,
      x1e-nixos-config,
    }@inputs:
    {
      # So that `nix fmt` can work
      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt;

      # Lenovo Yoga Slim 7x (Snapdragon X Elite) configuration
      nixosConfigurations.yoga-slim-7x = nixpkgs.lib.nixosSystem {
        # This line makes `inputs` available in all NixOS modules:
        specialArgs = { inherit inputs; };

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
          ./system/configuration.nix

          # Home Manager: sets up my desktop environment, apps, etc.
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.t = import ./user/home.nix;
              backupFileExtension = "old";
            };
          }
        ];
      };
    };
}
