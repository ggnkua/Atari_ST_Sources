ls -al acsc.s >version.d
sed -f fixver version.d >version.s
mac -dSCDMA=0 -p -o acscnd.prg acsc.s
mac -dSCDMA=1 -p -o acsc.prg acsc.s
