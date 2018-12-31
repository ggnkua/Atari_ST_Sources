as68 -l -u instal.s
cp68 install.c install.i
c068 install.i install.1 install.2 install.3 -f
rm install.i
c168 install.1 install.2 install.s
rm install.1
rm install.2
as68 -l -u install.s
rm install.s
link68 install.68k=accstart,install,instal,osbind,vdibind,aesbind
rm instal.o
rm install.o
relmod install.68k install.acc
rm install.68k
wait

