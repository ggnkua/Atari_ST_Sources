#
#  Makefile for lharc
#	needs TC 1.5
#
#  To make Japanese version
#		make
#		or	make -Dlang=Japanes
#
#  To make English version
#		make -Dlang=English
#

!if !$d(lang)
lang = English
!endif

asm = optasm
linker = tlink
sw = -D$(lang) -M -w-rvl -y -O -Z -d -k-

lharc.exe : lharc.obj huf.obj lzs.obj usage.obj\
		sfxbin.obj sfx2bin.obj execute.obj
	tcc $(sw) -elharc.exe sfxbin.obj sfx2bin.obj lharc.obj\
		lzs.obj huf.obj execute.obj usage.obj

.c.obj :
	tcc -c $(sw) $*

huf.obj : huf.asm
	$(asm) /e /ml $*;

lzs.obj : lzs.asm
	$(asm) /e /ml $*;

sfxbin.obj : sfx.asm
	$(asm) /e /ml sfx;
	$(linker) sfx,,sfx/m;
	exe2bin sfx sfx.bin
	bgiobj sfx.bin sfxbin _sfx
# To change segment allignment (para -> byte)
	symdeb /"e 11a 28;w;q" sfxbin.obj

sfx2bin.obj : sfx2.asm
	$(asm) /e /ml sfx2;
	$(linker) sfx2,,sfx2/m;
	exe2bin sfx2 sfx2.bin
	bgiobj sfx2.bin sfx2bin _sfx2
# To change segment allignment (para -> byte)
	symdeb /"e 11a 28;w;q" sfx2bin.obj

execute.obj : execute.c
	tcc -c -S $(sw) $*
	$(asm) /e /ml $*;

usage.obj : usage_$(lang).c
	tcc -c -ousage $(sw) usage_$(lang)

.cls.asm :
	amscls $* $*
