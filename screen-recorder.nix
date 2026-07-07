# screen-recorder.nix
{ pkgs }:

pkgs.writeShellApplication {
  name = "screen-recorder";

  runtimeInputs = with pkgs; [
    wf-recorder
    libnotify # Provides notify-send
    sway # Provides swaymsg
    jq
    pulseaudio # Provides pactl
    procps # Provides pidof
  ];

  text = ''
        NOTIF_TITLE='Screen recorder'
        LOGFILE='/tmp/screen-recorder.log'

        output() {
            notify-send -t 3000 "$NOTIF_TITLE" "$@"
            echo "$@" >>"$LOGFILE"
        }

        if pidof wf-recorder >/dev/null; then
            output 'There is already an instance of wf-recorder running!'
            exit 1
        fi

        OUTPUT="$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')"
        AUDIO_DEVICE="$(pactl info | awk '/Default Sink:/ {print $3}').monitor"
        FILE="$HOME/recording_$(date +'%Y-%m-%d_%H:%M:%S.mp4')"

        output "Starting! Recording output $OUTPUT"

    if ! wf-recorder \
        --codec h264_vaapi \
        --framerate 60 \
        --filter scale_vaapi=format=nv12,scale_vaapi=1280:720 \
        --output "$OUTPUT" \
        --audio="$AUDIO_DEVICE" \
        --file "$FILE" \
        &>>"$LOGFILE"
    then
        output "Failed to start wf-recorder! See $LOGFILE"
        exit 1
    fi

        output "Finished! Video saved at $FILE"
  '';
}
