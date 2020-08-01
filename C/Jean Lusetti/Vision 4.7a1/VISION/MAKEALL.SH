#!/bin/bash
PCMAKE_TTP=/h/PURE_C/pcmake.ttp
$PCMAKE_TTP -B VISIOND.PRJ
$PCMAKE_TTP -B VISIONL.PRJ
$PCMAKE_TTP -B VISION.PRJ

LDVSRC=LDV/SRC
LDVs=("bhole" "bw" "gamma" "invert" "light" "pixel" "puzzle" "rotate" "xwave" "ypersc" "ywave" "cntcol" "genimg")
find $LDVSRC -name "*.pdb" -type f -print0 | xargs -0 rm -f
find $LDVSRC -name "*.o" -type f -print0 | xargs -0 rm -f
for ldv in "${LDVs[@]}"
do
  $PCMAKE_TTP -B $LDVSRC/$ldv/$ldv.prj
  cp $LDVSRC/$ldv/$ldv.ldv LDV/
  rm $LDVSRC/$ldv/*.o
done

./vpack.sh