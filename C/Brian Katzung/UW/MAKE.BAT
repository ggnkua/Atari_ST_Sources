# This file has not been maintained and is not supported
cp68 -i \dric.dir\ -i %1 %1winmain.c %1winmain.i
c068 %1winmain.i %1winmain.1 %1winmain.2 %1winmain.3 -f
rm %1winmain.i
c168 %1winmain.1 %1winmain.2 %1winmain.s
rm %1winmain.1
rm %1winmain.2
as68 -l -u %1winmain.s
rm %1winmain.s
cp68 -i \dric.dir\ -i %1 %1winsubr.c %1winsubr.i
c068 %1winsubr.i %1winsubr.1 %1winsubr.2 %1winsubr.3 -f
rm %1winsubr.i
c168 %1winsubr.1 %1winsubr.2 %1winsubr.s
rm %1winsubr.1
rm %1winsubr.2
as68 -l -u %1winsubr.s
rm %1winsubr.s
link68 [u] %1wind.68k=gemstart,%1winsubr,%1winmain,vdibind,gemlib,aesbind,osbind,libf
relmod %1wind
rm %1wind.68k
