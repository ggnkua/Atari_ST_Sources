rem "Making GEMDOSHI.SYS for the 68010"
rem >disk.h "#define floppy 0"
c10 @cfls
asm @sfls
lc lisa10hi
link68 command.rel = coma,cmd10,lmul
relmod command.rel command.prg
