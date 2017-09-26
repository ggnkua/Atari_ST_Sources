rem "Making GEMDOSHI.SYS for the 68000"
rem >disk.h "#define floppy 0"
c @cfls
asm @sfls
lc lisahi
link68 command.rel = coma,command,lmul
relmod command.rel command.prg
