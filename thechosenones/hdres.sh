set -x

if [[ "$1" = "1440" ]]; then
  xrandr --output Virtual-1 --mode 2560x1440
elif [[ "$1" = "1496" ]]; then
  xrandr --newmode "1496x1000"  123.70  1496 1584 1744 1992  1000 1001 1004 1035  -HSync +Vsync
  xrandr --addmode Virtual-1 1496x1000
  xrandr --output Virtual-1 --mode 1496x1000
else
  xrandr --newmode "1920x1080" 241.50 2560 2600 2632 2720 1440 1443 1448 1481 -hsync +vsync
  xrandr --addmode Virtual-1 1920x1080
  xrandr --output Virtual-1 --mode 1920x1080
fi
