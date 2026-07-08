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
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "26.11";

  # Enable user-font discovery
  fonts.fontconfig.enable = true;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # 1. User-specific Bash Configuration
  programs.bash = {
    enable = true; # Ensures Home Manager manages your user's bash

    shellAliases = {
      usermount = "sudo mount -o uid=$USER,gid=$GROUPS";
      # yt-dlp = "yt-dlp --remote-components ejs:github --embed-metadata --embed-thumbnail";

      # Single quotes around the alias string mean we use double quotes inside jq safely
      tearing-nodes = "swaymsg -t get_tree | jq '.. | select(.allow_tearing? == true) | {name, type}'";

      # These variables allow for screen tearing (allow_tearing in sway config)
      sway = "WLR_DRM_NO_MODIFIERS=1 WLR_DRM_NO_ATOMIC=1 sway";
    };
  };
}
