{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    inter
  ];

  # 2. The Nix Way to Force Adwaita-Dark
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    # Explicitly set the GTK window interface font
    font = {
      name = "Inter";
      size = 11;
      package = pkgs.inter;
    };

    # Force the dark mode preference for GTK3 and GTK4/libadwaita apps
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Also force the system-wide dconf dark preference for libadwaita/flatpaks
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "Inter 11";
      document-font-name = "Inter 11"; # Optional: keeps documents matching
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Adwaita";
    package = pkgs.gnome-themes-extra;
    size = 20;
  };
}
