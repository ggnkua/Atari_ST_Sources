#!/bin/bash
convert $1 -coalesce -colors 13 -depth 4 +dither -resize $2 $3
