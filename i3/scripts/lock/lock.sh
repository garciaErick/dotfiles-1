#!/bin/bash

# Defaults
# All options are here: http://www.imagemagick.org/Usage/blur/#blur_args
#BLURTYPE="0x5"
#BLURTYPE="0x2"
#BLURTYPE="5x3"
BLURTYPE="2x8"
#BLURTYPE="2x3"

DISPLAY_RE="([0-9]+)x([0-9]+)\\+([0-9]+)\\+([0-9]+)"
IMAGE_RE="([0-9]+)x([0-9]+)"
FOLDER="$(dirname "$(readlink -f "$0")")"
LOCK="$FOLDER/lock.png"
TEXT="$FOLDER/text.png"
PARAMS=""
OUTPUT_IMAGE="/tmp/i3lock.png"
DISPLAY_TEXT=true
PIXELATE=false

# Read user input
POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
  -n|--no-text)
    DISPLAY_TEXT=false
    shift # past argument
    ;;
  -p|--pixelate)
    PIXELATE=true
    shift # past argument
    ;;
  *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

#Take screenshot:
scrot -z $OUTPUT_IMAGE

#Get dimensions of the lock image:
LOCK_IMAGE_INFO=`identify $LOCK`
[[ $LOCK_IMAGE_INFO =~ $IMAGE_RE ]]
IMAGE_WIDTH=${BASH_REMATCH[1]}
IMAGE_HEIGHT=${BASH_REMATCH[2]}

if $DISPLAY_TEXT ; then
  #Get dimensions of the text image:
  TEXT_IMAGE_INFO=`identify $TEXT`
  [[ $TEXT_IMAGE_INFO =~ $IMAGE_RE ]]
  TEXT_WIDTH=${BASH_REMATCH[1]}
  TEXT_HEIGHT=${BASH_REMATCH[2]}
fi

#Execute xrandr to get information about the monitors:
while read LINE
do
  #If we are reading the line that contains the position information:
  if [[ $LINE =~ $DISPLAY_RE ]]; then
    #Extract information and append some parameters to the ones that will be given to ImageMagick:
    WIDTH=${BASH_REMATCH[1]}
    HEIGHT=${BASH_REMATCH[2]}
    X=${BASH_REMATCH[3]}
    Y=${BASH_REMATCH[4]}
    POS_X=$(($X+$WIDTH/2-$IMAGE_WIDTH/2))
    POS_Y=$(($Y+$HEIGHT/2-$IMAGE_HEIGHT/2))

    PARAMS="$PARAMS '$LOCK' '-geometry' '+$POS_X+$POS_Y' '-composite'"

    if $DISPLAY_TEXT ; then
        TEXT_X=$(($X+$WIDTH/2-$TEXT_WIDTH/2))
        TEXT_Y=$(($Y+$HEIGHT/2-$TEXT_HEIGHT/2+200))
        PARAMS="$PARAMS '$TEXT' '-geometry' '+$TEXT_X+$TEXT_Y' '-composite'"
    fi
  fi
done <<<"`xrandr`"

#Execute ImageMagick:
if $PIXELATE ; then
  PARAMS="'$OUTPUT_IMAGE' '-scale' '10%' '-scale' '1000%' $PARAMS '$OUTPUT_IMAGE'"
else
  PARAMS="'$OUTPUT_IMAGE' '-level' '0%,100%,0.6' '-blur' '$BLURTYPE' $PARAMS '$OUTPUT_IMAGE'"
fi

eval convert $PARAMS

#Lock the screen:
i3lock -i $OUTPUT_IMAGE -t

#Remove the generated image:
rm $OUTPUT_IMAGE
