{ pkgs, lib, ... }:

{
  boot.loader.systemd-boot = {
    enable = true;

    # The default EFI partition created by Windows is really small, limit to 2
    # generations to be on the safe side.
    configurationLimit = 2;
  };

  boot.initrd.systemd = {
    enable = true;

    # This is not secure, but it makes diagnosing errors easier.
    emergencyAccess = true;
  };

  # Re-enable hardware video decoding kernel module.
  # Seems to be working fine for me within Firefox and ffmpeg.
  boot.blacklistedKernelModules = lib.mkForce [];

  services.automatic-timezoned.enable = true;

  hardware.enableRedistributableFirmware = true;

  nixpkgs.config.allowUnfree = true;

  # this is REQUIRED for sway
  hardware.graphics.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/SYSTEM_DRV";
      fsType = "vfat";
    };
  };

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

  # Enable the Geoclue location service daemon
  services.geoclue2.enable = true;

  # Tell the system to use geoclue2 as the provider
  location.provider = "geoclue2";

  # We're on ARM now, might as well! Only added 12MB to the install.
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
