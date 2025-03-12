longeven:	MACRO
		DS.B	4-(*&3)
		ENDM

	TEXT

START:
	clr.w	-(sp)
	trap	#1

	DATA

yo_tbl:
	REPT	2
	DC.W	"YO"
	ENDR
	DC.B	"D"

	longeven
dude_tbl:
	DC.L	"DUDE"
	DC.L	"THIS"
	DC.L	"REWL"

	BSS

word:	DS.W	1

	longeven
long_tbl:
	DS.L	5

	TEXT

SUBROUTINE:
	move.l	d0,d0
	rts