# screen-recorder.nix
{ pkgs }:

pkgs.writeShellApplication {
  name = "screen-recorder";

  runtimeInputs = with pkgs; [
    wf-recorder
    libnotify # notify-send
    pulseaudio
  ];

  text = builtins.readFile ./screen-recorder.sh;
}
