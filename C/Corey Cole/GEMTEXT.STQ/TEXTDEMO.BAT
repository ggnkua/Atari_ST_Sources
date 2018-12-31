cp68 debug.c debug.i
c068 debug.i debug.1 debug.2 debug.3 -f
rm debug.i
c168 debug.1 debug.2 debug.s
rm debug.1
rm debug.2
as68 -l -u debug.s
rm debug.s
cp68 textdemo.c textdemo.i
c068 textdemo.i textdemo.1 textdemo.2 textdemo.3 -f
rm textdemo.i
c168 textdemo.1 textdemo.2 textdemo.s
rm textdemo.1
rm textdemo.2
as68 -l -u textdemo.s
rm textdemo.s
link68 textdemo.68k=apstart,textdemo,debug,osbind,vdibind,aesbind
rm textdemo.o
rm debug.o
relmod textdemo
rm textdemo.68k
wait

