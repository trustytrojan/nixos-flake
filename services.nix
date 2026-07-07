{ config, pkgs, ... }:

let
  # Create a shorthand variable for the configured swaylock binary path
  swaylockBin = "${config.programs.swaylock.package}/bin/swaylock";
in
{
  services.gammastep = {
    enable = true;
    provider = "geoclue2"; # Hooks directly into the system's GeoClue service
    tray = true;

    # Optional styling tweaks
    temperature = {
      day = 5700;
      night = 2500;
    };

    # Force Gammastep to use the Wayland backend protocol explicitly
    settings = {
      general = {
        adjustment-method = "wayland";
      };
    };
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = swaylockBin;
      }
      {
        timeout = 600;
        command = "${pkgs.sway}/bin/swaymsg \"output * power off\"";
        resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * power on\"";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = swaylockBin;
      }
    ];
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      # Boolean flags
      screenshots = true;
      clock = true;
      indicator = true;
      submit-on-touch = true;
      show-failed-attempts = true;
      ignore-empty-password = true;

      # Values & Styling
      fade-in = 1;
      effect-blur = "7x5";
      font = "Iosevka";
      ring-color = "007777";
      text-color = "00cccc";
    };
  };

  # Mako Notification Daemon Configuration
  services.mako = {
    enable = true;
    settings = {
      font = "Iosevka 10";
      border-radius = 10;
      margin = 10;
      layer = "overlay";
    };
    extraConfig = ''
      history=0
      max-history=0
    '';
  };

  services.polkit-gnome.enable = true;
}
