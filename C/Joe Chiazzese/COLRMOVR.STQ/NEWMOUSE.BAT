as68 -l -u karate.s
as68 -l -u coeutil.s
cp68 newmouse.c newmouse.i
c068 newmouse.i newmouse.1 newmouse.2 newmouse.3 -f
rm newmouse.i
c168 newmouse.1 newmouse.2 newmouse.s
rm newmouse.1
rm newmouse.2
as68 -l -u newmouse.s
rm newmouse.s
link68 newmouse.68k=apstart,newmouse,coeutil,karate,osbind,vdibind,aesbind
rm newmouse.o
rm karate.o
rm coeutil.o
relmod newmouse
rm newmouse.68k
wait

