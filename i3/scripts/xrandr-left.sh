
EXT=DP-2
INT=eDP-1
xrandr --output $EXT --auto
ext_w=`xrandr | sed 's/^'"${EXT}"' [^0-9]* \([0-9]\+\)x.*$/\1/p;d'`
ext_h=`xrandr | sed 's/^'"${EXT}"' [^0-9]* [0-9]\+x\([0-9]\+\).*$/\1/p;d'`
int_w=`xrandr | sed 's/^'"${INT}"' [^0-9]* \([0-9]\+\)x.*$/\1/p;d'`
int_h=`xrandr | sed 's/^'"${INT}"' [^0-9]* [0-9]\+x\([0-9]\+\).*$/\1/p;d'`
off_w=`$(( $ext_w*2 ))`

xrandr --output "${INT}" --auto --right-of "${EXT}" --pos 2680x1050 --scale 1x1 --output "${EXT}" --auto --scale 2x2 --pos 0x0
