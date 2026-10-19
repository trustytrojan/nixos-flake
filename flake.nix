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
    }:
    let
      # Supported systems for general flake outputs (like formatters)
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      # Helper function to generate attributes for each supported system
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      # Lenovo Yoga Slim 7x (Snapdragon X Elite) configuration
      nixosConfigurations.yoga-slim-7x = nixpkgs.lib.nixosSystem {
        modules = [
          # Hardware support module. Does a lot of work.
          x1e-nixos-config.nixosModules.x1e

          # Inline NixOS configuration settings specific to the Yoga Slim 7x
          ({ lib, pkgs, ... }: {
            networking.hostName = "yoga-slim-7x";
            hardware.lenovo-yoga-slim7x.enable = true;
            nixpkgs.hostPlatform.system = "aarch64-linux";

            boot = {
              # See flake inputs.
              kernelPackages = nixpkgs-kernel.legacyPackages.${pkgs.system}.linuxPackages_7_2;

              # Unblacklist qcom_iris for hardware video acceleration.
              blacklistedKernelModules = lib.mkForce [ ];
            };

            fileSystems = {
              "/" = {
                label = "root";
                fsType = "ext4";
              };

              # EFI system partition (ESP)
              "/boot" = {
                label = "SYSTEM_DRV";
                fsType = "vfat";
              };

              # Shared data partition with Windows
              "/mnt/shared" = {
                label = "Shared";
                fsType = "ntfs";
              };
            };
          })

          # Hardware-agnostic system configuration
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
