{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    iosevka-bin
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans-static
  ];
}
