CP68 sbody.c sbody.i
c068 sbody.i sbody.1 sbody.2 sbody.3 -f
c168 sbody.1 sbody.2 sbody.s
rm sbody.i
rm sbody.1
rm sbody.2
as68 -U sbody.s
CP68 io.c io.i
c068 io.i io.1 io.2 io.3 -f
c168 io.1 io.2 io.s
rm io.i
rm io.1
rm io.2
as68 -U io.s
as68 -U dat1.s
link68 [u,s] klondike.68k=apstart,sbody,io,aesbind,vdibind,osbind,dat1
relmod klondike.68k klondike.prg
rm klondike.68k
rm sbody.o
rm io.o
rm dat1.o
wait


