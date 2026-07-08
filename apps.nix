{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
    dex
    brightnessctl
    grim
    slurp
    wl-clipboard
    pavucontrol
    nvtopPackages.msm # should make this the full variant when I test this flake on other systems
    xdg-utils
    jq
    nemo
    nemo-fileroller
  ];

  # should move this to a "desktop-environment.nix" or sway-related file or something
  programs.wofi.enable = true;

  programs.vscode.enable = true;

  programs.yt-dlp = {
    enable = true;
    settings = {
      embed-thumbnail = true;
      embed-metadata = true;
      remote-components = "ejs:github";
    };
  };

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };

  xdg.configFile."vesktop/themes/tt-cv.css" = {
    source = pkgs.fetchurl {
      url = "https://github.com/trustytrojan/dotfiles/raw/refs/heads/main/.config/vesktop/themes/tt-cv.css";
      # Use `nix store prefetch-file <url>` to get the hash to paste below
      hash = "sha256-3YRBpSdFr63SF4oB1/JSDUOa3UMBEoUChvxzFiug4hg=";
    };
  };

  programs.vesktop = {
    enable = true;
    settings = {
      hardwareVideoAcceleration = true;
    };
  };

  programs.librewolf = {
    enable = true;
    # raw 'settings' object doesn't work. have to wrap inside a profile.
    profiles.default = {
      settings = {
        "privacy.resistFingerprinting" = false;
        "identity.fxaccounts.enabled" = true;
        "media.autoplay.blocking_policy" = 2;
      };
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Iosevka:size=12";
      };

      colors-dark = {
        alpha = 0.25;
        cursor = "002b36 93a1a1";
        background = "202020";
        foreground = "a3b4b6";

        regular0 = "073642";
        regular1 = "dc322f";
        regular2 = "859900";
        regular3 = "b58900";
        regular4 = "268bd2";
        regular5 = "d33682";
        regular6 = "2aa198";
        regular7 = "eee8d5";

        bright0 = "08404f";
        bright1 = "e35f5c";
        bright2 = "9fb700";
        bright3 = "d9a400";
        bright4 = "4ba1de";
        bright5 = "dc619d";
        bright6 = "32c1b6";
        bright7 = "ffffff";
      };
    };
  };
}
