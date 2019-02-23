cp68 mag21.c mag21.i
c068 mag21.i mag21.1 mag21.2 mag21.3 -f
rm mag21.i
c168 mag21.1 mag21.2 mag21.s
rm mag21.1
rm mag21.2
as68 -l -u mag21.s
rm mag21.s
link68 mag21.68k=apstart,mag21,osbind,libf,vdibind,aesbind
rm mag21.o
relmod mag21
rm mag21.68k
wait

