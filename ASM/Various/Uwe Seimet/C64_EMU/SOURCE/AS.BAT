as68.prg -l -u %1.s
link68.prg c64.68k=c64.o,vc.o,emulator.o
relmod.prg c64.68k c64.tos
