{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./sway.nix
    ./waybar.nix
    ./theme.nix
    ./apps.nix
    ./services.nix
    ./fonts.nix
  ];

  # 1. Mandatory Boilerplate
  home = {
    username = "t";
    homeDirectory = "/home/t";
    stateVersion = "26.11";
  };

  # Enable user-font discovery
  fonts.fontconfig.enable = true;

  programs = {
    # Let Home Manager install and manage itself
    home-manager.enable = true;

    git = {
      enable = true;
      settings = {
        user.name = "trustytrojan";
        user.email = "t@trustytrojan.dev";
        pull.rebase = false;
      };
      ignores = [
        ".vscode"
        ".cache"
        ".direnv"
        "compile_commands.json"
      ];
    };

    bash = {
      enable = true;
      shellAliases = {
        # Mount a filesystem owned by my user
        usermount = "sudo mount -o uid=$USER,gid=$GROUPS";

        # Uncomment when you actually make use of yt-dlp
        # yt-dlp = "yt-dlp --remote-components ejs:github --embed-metadata --embed-thumbnail";

        # Prints all sway nodes that have allow_tearing enabled, good for debugging
        tearing-nodes = "swaymsg -t get_tree | jq '.. | select(.allow_tearing? == true) | {name, type}'";

        # Inject environment variables needed for screen tearing
        sway = "WLR_DRM_NO_MODIFIERS=1 WLR_DRM_NO_ATOMIC=1 sway";

        # This is the only reliable way to run gparted. Running it in a subshell lets the original
        # shell exit so that the launching terminal can get out of the way. This is required because
        # the `pkexec` binary shipped in the gparted package has its setuid bit disabled.
        gparted = "(sudo -E nix run nixpkgs#gparted &); exit";
      };
    };
  };
}
