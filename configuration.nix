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

  users.users.user = {
    isNormalUser = true;
    # Default password, should be changed using `passwd` after first login.
    password = "nixos";
    extraGroups = [
      "wheel"
      "networkmanager"
      "corectrl"
    ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  security.sudo.wheelNeedsPassword = false;

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  networking.networkmanager = {
    enable = true;
    plugins = lib.mkForce [ ];
  };

  hardware.bluetooth.enable = true;

  hardware.pulseaudio.enable = false;
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
    promptInit = ''
      set_ps1() {
          # Color/style escape sequences
          bold() { echo '\[\e[1;'$1'm\]'; }
          local RESET='\[\e[0m\]'
          local CYAN=$(bold 36)
          local RED=$(bold 31)
          local WHITE=$(bold 37)
          local BLUE=$(bold 34)
          unset bold

          # Red username and `#` are reserved for root
          local USER PROMPT_CHAR
          if [ $UID = 0 ]; then
              USER_COLOR=$RED
              PROMPT_CHAR=\#
          else
              USER_COLOR=$WHITE
              PROMPT_CHAR=\$
          fi

          # Decide bracket color based on distro
          local BRACKET
          case $(grep '^ID=' /etc/os-release | cut -d'=' -f2) in
              nixos)   BRACKET=$CYAN ;; # Changed 'arch' to 'nixos'
              debian)  BRACKET=$RED ;;
              *)       BRACKET=$CYAN ;; # Fallback just in case
          esac

          # Colored prompt
          PS1="$BRACKET[ $USER_COLOR\u$RESET@\H $BLUE\W $BRACKET]$RESET$PROMPT_CHAR "
      }

      set_ps1
      unset set_ps1
    '';
  };

  # Enable the Geoclue location service daemon
  services.geoclue2.enable = true;

  # Tell the system to use geoclue2 as the provider
  location.provider = "geoclue2";
}
