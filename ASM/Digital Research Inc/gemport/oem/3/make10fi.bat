rem "Making GEMDOSFI.SYS for the 68010"
rem >disk.h "#define floppy 1"
c10 @cfls
asm @sfls
lc lisa10
link68 command.rel = coma,cmd10,lmul
relmod command.rel command.prg
