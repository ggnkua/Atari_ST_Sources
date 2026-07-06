d:cc -id: -od:yc.out %1.c
as d:prg.s d:yc.out -l d:gem.a d:lib.a d:extra.a
rm %1.prg d:yc.out
ren ya.out %1.prg
