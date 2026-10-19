{
  lib,
  pkgs,
  inputs,
  ...
}:

# NixOS configuration settings specific to the Yoga Slim 7x
{
  networking.hostName = "yoga-slim-7x";
  hardware.lenovo-yoga-slim7x.enable = true;
  nixpkgs.hostPlatform.system = "aarch64-linux";

  boot = {
    # See `flake.nix`.
    kernelPackages = inputs.nixpkgs-kernel.legacyPackages.${pkgs.system}.linuxPackages_7_2;

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
}
