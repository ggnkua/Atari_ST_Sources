rem "Making GEMDOSFI.SYS for the 68000"
rem >disk.h "#define floppy 1"
c @cfls
asm @sfls
lc lisa
link68 command.rel = coma,command,lmul
relmod command.rel command.prg
