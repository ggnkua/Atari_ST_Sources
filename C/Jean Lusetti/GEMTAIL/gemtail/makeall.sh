#!/bin/bash
PCMAKE_TTP=/h/PURE_C/pcmake.ttp
$PCMAKE_TTP -B GEMTAILD.PRJ
$PCMAKE_TTP -B GEMTAIL.PRJ

./gtpack.sh