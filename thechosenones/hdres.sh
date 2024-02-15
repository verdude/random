set -xEeuo pipefail

mapfile -t screens < <(xrandr | awk '/DP\-. connected/ {print $1}')

if [[ "${#screens[@]}" -eq 1 ]] && [[ "${screens[0]}" == "Virtual-1" ]]; then
  echo "top"
  exit
  xrandr --addmode Virtual-1 2560x1440
  xrandr --output Virtual-1 --primary --mode 2560x1440
elif [[ "${#screens[@]}" -eq 2 ]] && [[ "${screens[0]}" =~ ^DP-[0-9]+$ ]]; then
  xrandr --output DP-2 --primary --mode 3840x2160 --rate 144
  xrandr --output DP-0 --mode 2560x1440 --rate 144 --right-of DP-2
else
  echo "double bottomt"
  exit
  xrandr --addmode HDMI2 2560x1440
  xrandr --output HDMI2 --primary --mode 2560x1440 --rate 144
  xrandr --output DP1 --mode 2560x1440 --rate 144
  xrandr --output HDMI2 --left-of DP1
  xrandr --output eDP1 --off
fi
