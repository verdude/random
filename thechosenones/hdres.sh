set -xEeuo pipefail

mapfile -t screens < <(xrandr | grep " connected" | awk '{print $1}')

if [[ "${#screens[@]}" -eq 1 ]] && [[ "${screens[0]}" == "Virtual-1" ]]; then
  xrandr --addmode Virtual-1 2560x1440
  xrandr --output Virtual-1 --primary --mode 2560x1440
else
  xrandr --addmode HDMI2 2560x1440
  xrandr --output HDMI2 --primary --mode 2560x1440 --rate 144
  xrandr --output DP1 --mode 2560x1440 --rate 144
  xrandr --output HDMI2 --left-of DP1
  xrandr --output eDP1 --off
fi
