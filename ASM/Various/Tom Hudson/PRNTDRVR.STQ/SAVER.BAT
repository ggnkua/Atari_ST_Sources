as68 -l -u epson.s
cp68 saver.c saver.i
c068 saver.i saver.1 saver.2 saver.3 -f
rm saver.i
c168 saver.1 saver.2 saver.s
rm saver.1
rm saver.2
as68 -l -u saver.s
rm saver.s
link68 saver.68k=apstart,saver,epson,osbind,vdibind,aesbind
rm epson.o
rm saver.o
relmod saver.68k epson.prg
rm saver.68k
wait

