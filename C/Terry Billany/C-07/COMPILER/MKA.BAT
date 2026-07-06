d:cc -id: -od:yc.out %1.c
as d:acc.s d:yc.out -l d:gem.a d:lib.a d:extra.a
rm %1.acc d:yc.out
ren ya.out %1.acc
