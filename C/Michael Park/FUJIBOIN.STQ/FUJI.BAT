cp68 fujidraw.c fujidraw.i
c068 fujidraw.i fujidraw.1 fujidraw.2 fujidraw.3 -f
rm fujidraw.i
c168 fujidraw.1 fujidraw.2 fujidraw.s
rm fujidraw.1
rm fujidraw.2
as68 -l -u fujidraw.s
rm fujidraw.s

link68 [u,s] fujidraw.68k=apstart,fujidraw,vdibind,aesbind,osbind,libf
rm fujidraw.o
relmod fujidraw.68k fujidraw.prg
rm fujidraw.68k

cp68 fujishad.c fujishad.i
c068 fujishad.i fujishad.1 fujishad.2 fujishad.3 -f
rm fujishad.i
c168 fujishad.1 fujishad.2 fujishad.s
rm fujishad.1
rm fujishad.2
as68 -l -u fujishad.s
rm fujishad.s

link68 [u,s] fujishad.68k=apstart,fujishad,vdibind,aesbind,osbind,libf
rm fujishad.o
relmod fujishad.68k fujishad.prg
rm fujishad.68k

cp68 gettitle.c gettitle.i
c068 gettitle.i gettitle.1 gettitle.2 gettitle.3 -f
rm gettitle.i
c168 gettitle.1 gettitle.2 gettitle.s
rm gettitle.1
rm gettitle.2
as68 -l -u gettitle.s
rm gettitle.s

link68 [u,s] gettitle.68k=apstart,gettitle,vdibind,aesbind,osbind,libf
rm gettitle.o
relmod gettitle.68k gettitle.prg
rm gettitle.68k

cp68 pend.c pend.i
c068 pend.i pend.1 pend.2 pend.3 -f
rm pend.i
c168 pend.1 pend.2 pend.s
rm pend.1
rm pend.2
as68 -l -u pend.s
rm pend.s

link68 [u,s] pend.68k=apstart,pend,vdibind,aesbind,osbind,libf
rm pend.o
relmod pend.68k pend.prg
rm pend.68k

as68 -l fujistuf.s

cp68 fujiboin.c fujiboin.i
c068 fujiboin.i fujiboin.1 fujiboin.2 fujiboin.3 -f
rm fujiboin.i
c168 fujiboin.1 fujiboin.2 fujiboin.s
rm fujiboin.1
rm fujiboin.2
as68 -l -u fujiboin.s
rm fujiboin.s

link68 [u,s] fujiboin.68k=apstart,fujiboin,fujistuf,vdibind,aesbind,osbind
rm fujiboin.o
relmod fujiboin.68k fujiboin.prg
rm fujiboin.68k

wait

