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
      settings.user = {
        name = "trustytrojan";
        email = "t@trustytrojan.dev";
      };
    };

    bash = {
      enable = true;
      shellAliases = {
        usermount = "sudo mount -o uid=$USER,gid=$GROUPS";
        # yt-dlp = "yt-dlp --remote-components ejs:github --embed-metadata --embed-thumbnail";
        tearing-nodes = "swaymsg -t get_tree | jq '.. | select(.allow_tearing? == true) | {name, type}'";
        sway = "WLR_DRM_NO_MODIFIERS=1 WLR_DRM_NO_ATOMIC=1 sway";
      };
    };
  };
}
