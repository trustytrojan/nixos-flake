{
  pkgs,
  lib,
  ...
}:

# TODO: Make this system configuration hardware-agnostic, if possible.
{
  boot = {
    # TODO: This might be hardware-specific to the Yoga Slim 7x.
    # If and when you use NixOS on an x86_64 PC, you might want GRUB instead.
    loader.systemd-boot = {
      enable = true;

      # The default EFI partition created by Windows is really small.
      # When this was set to 2, sometimes rebuilds failed because the ESP ran out of space.
      # Resizing the ESP means potentially reinstalling Windows on ARM, which sounds like a nightmare.
      # Just deal with 1 for now. You're used to the Arch lifestyle anyway.
      configurationLimit = 1;
    };

    initrd.systemd.enable = true;
  };

  hardware = {
    # Mainly for osu-lazer's built-in OTD to function properly
    opentabletdriver.enable = true;

    enableRedistributableFirmware = true;
    graphics.enable = true;
    bluetooth.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Some "build jobs" are actually curl downloads...
      # Same problem as max-substition-jobs being too high.
      max-jobs = 8;

      # The default of 16 is a bit much.
      max-substitution-jobs = 8;
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

  security = {
    polkit.enable = true;
    rtkit.enable = true;

    # Might want this true on systems with fingerprint scanners.
    sudo.wheelNeedsPassword = false;

    # This is specific to systems with my Sway setup, but doesn't hurt to keep here.
    pam.services = {
      swaylock = {
        text = ''
          auth include login
        '';
      };

      # On user login, unlock GNOME Keyring with the same password used to login.
      # This will create a keyring called "Login" which is different from "Default Keyring".
      # So make sure to have this enabled before letting apps populate the keyring.
      login.enableGnomeKeyring = true;
    };
  };

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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # We're on ARM now, might as well! Only adds 12MB to the install.
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };

    dconf.enable = true;
    corectrl.enable = true;

    bash = {
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

    htop = {
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

    # This is great for isolating development environments
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
