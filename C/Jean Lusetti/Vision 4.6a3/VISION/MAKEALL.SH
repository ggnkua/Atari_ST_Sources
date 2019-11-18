#!/bin/bash
PCMAKE_TTP=/h/PURE_C/pcmake.ttp
$PCMAKE_TTP -B VISIOND.PRJ
$PCMAKE_TTP -B VISIONL.PRJ
$PCMAKE_TTP -B VISION.PRJ

LDVSRC=LDV/SRC
LDVs=( "bhole" "bw" "gamma" "invert" "light" "pixel" "puzzle" "rotate" "xwave" "ypersc" "ywave" )
for ldv in "${LDVs[@]}"
do
  $PCMAKE_TTP -B $LDVSRC/$ldv/$ldv.prj
  cp $LDVSRC/$ldv/$ldv.ldv LDV/
  rm $LDVSRC/$ldv/$ldv.o
done
