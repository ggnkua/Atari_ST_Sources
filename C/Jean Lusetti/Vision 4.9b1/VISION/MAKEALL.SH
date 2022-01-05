#!/bin/bash
PCMAKE_TTP=/h/PURE_C/pcmake.ttp
$PCMAKE_TTP -B VISIOND.PRJ
$PCMAKE_TTP -B VISIONL.PRJ
$PCMAKE_TTP -B VISION.PRJ

./makeldv.sh

./vpack.sh