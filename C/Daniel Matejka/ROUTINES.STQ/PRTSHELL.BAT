as68 -l -u memops.s
cp68 printout.c printout.i
c068 printout.i printout.1 printout.2 printout.3 -f
rm printout.i
c168 printout.1 printout.2 printout.s
rm printout.1
rm printout.2
as68 -l -u printout.s
rm printout.s
cp68 prtshell.c prtshell.i
c068 prtshell.i prtshell.1 prtshell.2 prtshell.3 -f
rm prtshell.i
c168 prtshell.1 prtshell.2 prtshell.s
rm prtshell.1
rm prtshell.2
as68 -l -u prtshell.s
rm prtshell.s
link68 prtshell.68k=apstart,prtshell,printout,memops,osbind,vdibind,aesbind
rm memops.o
rm printout.o
rm prtshell.o
relmod prtshell
rm prtshell.68k
wait

