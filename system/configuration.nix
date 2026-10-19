{ pkgs, lib, inputs, ... }:

# TODO: Make this system configuration hardware-agnostic, if possible.
{
  boot.loader.systemd-boot = {
    enable = true;

    # The default EFI partition created by Windows is really small.
    # When this was set to 2, sometimes rebuilds failed because the ESP ran out of space.
    # Resizing the ESP means potentially reinstalling Windows on ARM, which sounds like a nightmare.
    # Just deal with 1 for now. You're used to the Arch lifestyle anyway.
    configurationLimit = 1;
  };

  boot.initrd.systemd = {
    enable = true;

    # This is not secure, but it makes diagnosing errors easier.
    emergencyAccess = true;
  };

  boot.kernelPackages = inputs.nixpkgs-kernel.legacyPackages.${pkgs.system}.linuxPackages_7_2;

  # Re-enable hardware video decoding kernel module.
  # Seems to be working fine for me within Firefox and ffmpeg.
  boot.blacklistedKernelModules = lib.mkForce [ ];

  # Mainly for osu-lazer's built-in OTD to function properly
  hardware.opentabletdriver.enable = true;

  hardware.enableRedistributableFirmware = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    # Some "build jobs" are actually curl downloads...
    # Same problem as max-substition-jobs being too high.
    max-jobs = 8;
    # The default of 16 is a bit much.
    max-substitution-jobs = 8;
  };

  # this is REQUIRED for sway
  hardware.graphics.enable = true;

  # These mounts are specific to the yoga-slim-7x, move it to that output
  fileSystems = {
    # Root FS for NixOS
    "/" = {
      label = "root";
      fsType = "ext4";
    };
    # EFI system partition
    "/boot" = {
      label = "SYSTEM_DRV";
      fsType = "vfat";
    };
    # Shared data partition with Windows using Ext4Fsd
    "/mnt/shared" = {
      label = "Shared";
      fsType = "ext4";
    };
  };

  # This also might have to go to yoga-slim-7x output
  # Enable some SysRq keys (80 = sync + process kill)
  # See: https://docs.kernel.org/admin-guide/sysrq.html
  boot.kernel.sysctl."kernel.sysrq" = 80;

  # In case you're confused: users.<group>.<user>
  users.users.t = {
    isNormalUser = true;
    # Default password, should be changed using `passwd` after first login.
    password = "nixos";
    extraGroups = [
      "wheel"
      "networkmanager"
      "corectrl"
      "video"
    ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  security.polkit.enable = true;

  security.sudo.wheelNeedsPassword = false;

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # On user login, unlock GNOME Keyring with the same password used to login.
  # This will create a keyring called "Login" which is different from "Default Keyring".
  # So make sure to have this enabled before letting apps populate the keyring.
  security.pam.services.login.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    man-pages
    file
    ntfs3g
  ];

  networking.networkmanager = {
    enable = true;
    plugins = lib.mkForce [ ];
  };

  hardware.bluetooth.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.htop = {
    enable = true;
    settings = {
      hide_userland_threads = 1;
      show_program_path = 0;
      highlight_changes = 1;
      highlight_changes_delay_secs = 1;
      delay = 10;
      tree_view = 1;
    };
  };

  programs.dconf.enable = true;
  programs.corectrl.enable = true;

  # System-wide Bash Configuration
  programs.bash = {
    # 1. Essential Aliases
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lh";
      la = "ll -a";
      ip = "ip -c";
      du = "du -had1";
    };

    # 2. Custom PS1 Prompt Logic
    promptInit = builtins.readFile ./prompt-init.sh;
  };

  # We're on ARM now, might as well! Only adds 12MB to the install.
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  # This is great for isolating development environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
