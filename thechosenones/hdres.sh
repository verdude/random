set -xEeuo pipefail

xrandr --addmode HDMI2 2560x1440
xrandr --output HDMI2 --mode 2560x1440 --rate 144
xrandr --output DP1 --mode 2560x1440 --rate 144
xrandr --output HDMI2 --left-of DP1
xrandr --output eDP1 --off
