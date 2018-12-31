cp68 sequencr.c sequencr.i
c068 sequencr.i sequencr.1 sequencr.2 sequencr.3 -f
rm sequencr.i
c168 sequencr.1 sequencr.2 sequencr.s
rm sequencr.1
rm sequencr.2
as68 -l -u sequencr.s
rm sequencr.s
link68 sequencr.68k=apstart,sequencr,osbind,vdibind,aesbind
rm sequencr.o
relmod sequencr
rm sequencr.68k
wait

