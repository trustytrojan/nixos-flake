{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Step back two directories to reach screen-recorder.nix
  screen-recorder = import ./screen-recorder.nix { inherit pkgs; };
  swaylockBin = "${config.programs.swaylock.package}/bin/swaylock";
in
{
  home.file.".wallpaper.jpg".source = pkgs.fetchurl {
    url = "https://github.com/trustytrojan/dotfiles/raw/main/.wallpaper.jpg";
    hash = "sha256-kDGeQYErzNYtLH6W3V2U4rwI7YZkhbf8AkICnNWVdIM=";
  };

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;

    # On Yoga Slim 7x, this errors when in reality it works just fine.
    checkConfig = false;

    config = {
      modifier = "Mod4";
      terminal = "${pkgs.foot}/bin/foot";
      menu = "pidof wofi || ${pkgs.wofi}/bin/wofi --show=drun";

      bars = [
        { command = "true"; }
      ];

      # Fonts
      fonts = {
        names = [ "Iosevka" ];
        size = 10.0;
      };

      # Gaps & Borders
      gaps = {
        inner = 10;
        outer = 0;
      };
      window.border = 2;
      window.titlebar = false;

      # Custom Colors
      colors = {
        focused = {
          border = "#00cccc";
          background = "#00cccc";
          text = "#004444";
          indicator = "#00cccc";
          childBorder = "#00cccc";
        };
        unfocused = {
          border = "#00cccc";
          background = "#808080";
          text = "#eeeeee";
          indicator = "#808080";
          childBorder = "#808080";
        };
      };

      # Input Device Configuration
      input = {
        "type:keyboard" = {
          repeat_delay = "200";
        };
        "type:pointer" = {
          accel_profile = "flat";
        };
        "type:touchpad" = {
          accel_profile = "flat";
          click_method = "clickfinger";
          pointer_accel = "0.75";
        };
      };

      # Display Configuration
      output = {
        "*" = {
          bg = "~/.wallpaper.jpg fill";
          scale = "1.75";
        };
      };

      # Window Rules
      window.commands = [
        {
          command = "allow_tearing yes";
          criteria = {
            app_id = "osu!";
          };
        }
        {
          command = "inhibit_idle fullscreen";
          criteria = {
            class = ".*";
          };
        }
      ];

      # Startup Applications
      startup = [
        { command = "${pkgs.swayidle}/bin/swayidle"; }
        { command = "systemctl --user start gammastep"; }
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
        { command = "${pkgs.dex}/bin/dex -a"; }
        # Add this line to force focus to Workspace 1 on launch
        # idk why but sway starts in workspace 10 by default. do this to start in workspace 1
        { command = "swaymsg workspace number 1"; }
      ];

      # Keybindings
      keybindings =
        let
          mod = "Mod4";
        in
        lib.mkOptionDefault {
          # General
          "${mod}+l" = "exec ${swaylockBin}";
          "${mod}+Return" = "exec ${pkgs.foot}/bin/foot";
          "${mod}+q" = "kill";
          "${mod}+d" = "exec pidof wofi || ${pkgs.wofi}/bin/wofi --show=drun";
          "${mod}+Shift+c" = "reload";
          "${mod}+Shift+e" =
            "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";

          # Hardware Keys
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          "XF86MonBrightnessUp" = "exec brightnessctl s +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
          "XF86ScreenSaver" = "exec ${swaylockBin}";

          # Screenshots & Recording
          "Print" = "exec [ ! \$(pidof slurp) ] && grim -g \"\$(slurp)\" - | wl-copy";
          "Ctrl+Print" = "exec [ ! \$(pidof slurp) ] && grim -g \"\$(slurp)\"";
          "Shift+Print" = "exec [ ! \$(pidof slurp) ] && grim - | wl-copy";
          "Ctrl+Shift+Print" = "exec [ ! \$(pidof slurp) ] && grim";
          "Alt+Print" = "exec ${screen-recorder}/bin/screen-recorder";
          "Alt+BackSpace" = "exec killall -s SIGINT wf-recorder";

          # Window Focus & Movement
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          # Workspaces
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          # Move to Workspaces
          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";

          # Layouts
          "${mod}+h" = "splith";
          "${mod}+v" = "splitv";
          "${mod}+t" = "layout tabbed";
          "${mod}+Shift+l" = "layout toggle all";
          "${mod}+f" = "fullscreen";
          #"${mod}+Shift+Space" = "floating toggle";
          #"${mod}+Space" = "focus mode_toggle";
          "${mod}+a" = "focus parent";

          # Scratchpad
          "${mod}+Shift+minus" = "move scratchpad";
          "${mod}+minus" = "scratchpad show";

          # Resize Mode
          "${mod}+r" = "mode resize";
        };

      # Resize Mode Keybindings
      modes = {
        resize = {
          Left = "resize shrink width 10px";
          Right = "resize grow width 10px";
          Down = "resize grow height 10px";
          Up = "resize shrink height 10px";
          Return = "mode default";
          Escape = "mode default";
        };
      };
    };

    # SwayFX specific configuration extra lines
    extraConfig = ''
      blur enable
      corner_radius 5
    '';
  };
}
