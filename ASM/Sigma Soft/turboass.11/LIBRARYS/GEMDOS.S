;************************************************************************
;* GEMDOS-Library, öbergabe in Registern				*
;* Ω1989 by ‰-soft, written by Markus Fritze	       18.06.1988 01:16 *
;************************************************************************

pterm0: 	clr.w	-(SP)
		trap	#1

cconin: 	move.w	#1,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

cconout:	move.w	D0,-(SP)
		move.w	#2,-(SP)
		bsr	gemdos
		addq.l	#4,SP
		rts

cauxin: 	move.w	#3,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

cauxout:	move.w	D0,-(SP)
		move.w	#4,-(SP)
		bsr	gemdos
		addq.l	#4,SP
		rts

cprnout:	move.w	D0,-(SP)
		move.w	#5,-(SP)
		bsr	gemdos
		addq.l	#4,SP
		rts

crawio: 	move.w	D0,-(SP)
		move.w	#6,-(SP)
		bsr	gemdos
		addq.l	#4,SP
		rts

crawcin:	move.w	#7,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

cnecin: 	move.w	#8,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

cconws: 	move.l	A0,-(SP)
		move.w	#9,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

cconrs: 	move.l	A0,-(SP)
		move.w	#$0A,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

cconis: 	move.w	#$0B,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

dsetdrv:	move.w	D0,-(SP)
		move.w	#$0E,-(SP)
		bsr	gemdos
		addq.l	#4,SP
		rts

cconos: 	move.w	#$10,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

cprnos: 	move.w	#$11,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

cauxis: 	move.w	#$12,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

cauxos: 	move.w	#$13,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

dgetdrv:	move.w	#$19,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

fsetdta:	move.l	A0,-(SP)
		move.w	#$1A,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

super:		move.l	D0,-(SP)
		move.w	#$20,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

tgetdate:	move.w	#$2A,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

tsetdate:	move.w	D0,-(SP)
		move.w	#$2B,-(SP)
		bsr	gemdos
		addq.l	#4,SP
		rts

tgettime:	move.w	#$2C,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

tsettime:	move.w	D0,-(SP)
		move.w	#$2D,-(SP)
		bsr	gemdos
		addq.l	#4,SP
		rts

fgetdta:	move.w	#$2F,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

sversion:	move.w	#$30,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

ptermres:	move.w	D0,-(SP)
		move.l	D1,-(SP)
		move.w	#$31,-(SP)
		trap	#1

dfree:		move.w	D0,-(SP)
		move.l	A0,-(SP)
		move.w	#$36,-(SP)
		bsr	gemdos
		addq.l	#8,SP
		rts

dcreate:	move.l	A0,-(SP)
		move.w	#$39,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

ddelete:	move.l	A0,-(SP)
		move.w	#$3A,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

dsetpath:	move.l	A0,-(SP)
		move.w	#$3B,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

fcreate:	move.w	D0,-(SP)
		move.l	A0,-(SP)
		move.w	#$3C,-(SP)
		bsr	gemdos
		addq.l	#8,SP
		move.l	D0,D7
		rts

fopen:		move.w	D0,-(SP)
		move.l	A0,-(SP)
		move.w	#$3D,-(SP)
		bsr	gemdos
		addq.l	#8,SP
		move.l	D0,D7
		rts

fclose: 	move.w	D7,-(SP)
		move.w	#$3E,-(SP)
		bsr	gemdos
		addq.l	#4,SP
		rts

fread:		move.l	A0,-(SP)
		move.l	D0,-(SP)
		move.w	D7,-(SP)
		move.w	#$3F,-(SP)
		bsr	gemdos
		lea	12(SP),SP
		rts

fwrite: 	move.l	A0,-(SP)
		move.l	D0,-(SP)
		move.w	D7,-(SP)
		move.w	#$40,-(SP)
		bsr	gemdos
		lea	12(SP),SP
		rts

fdelete:	move.l	A0,-(SP)
		move.w	#$41,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

fseek:		move.w	D0,-(SP)
		move.w	D7,-(SP)
		move.l	D1,-(SP)
		move.w	#$42,-(SP)
		bsr	gemdos
		lea	10(SP),SP
		rts

fattrib:	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.l	A0,-(SP)
		move.w	#$43,-(SP)
		bsr	gemdos
		lea	10(SP),SP
		rts

fdup:		move.w	D0,-(SP)
		move.w	#$45,-(SP)
		bsr	gemdos
		addq.l	#4,SP
		rts

fforce: 	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	#$46,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

dgetpath:	move.w	D0,-(SP)
		move.l	A0,-(SP)
		move.w	#$47,-(SP)
		bsr	gemdos
		addq.l	#8,SP
		rts

malloc: 	move.l	D0,-(SP)
		move.w	#$48,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

mfree:		move.l	A0,-(SP)
		move.w	#$49,-(SP)
		bsr	gemdos
		addq.l	#6,SP
		rts

mshrink:	move.l	D0,-(SP)
		move.l	A0,-(SP)
		pea	$4A0000
		bsr	gemdos
		lea	12(SP),SP
		rts

pexec:		move.l	A2,-(SP)
		move.l	A1,-(SP)
		move.l	A0,-(SP)
		move.w	D0,-(SP)
		move.w	#$4B,-(SP)
		bsr	gemdos
		lea	16(SP),SP
		rts

pterm:		move.w	D0,-(SP)
		move.w	#$4C,-(SP)
		trap	#1

fsfirst:	move.w	D0,-(SP)
		move.l	A0,-(SP)
		move.w	#$4E,-(SP)
		bsr	gemdos
		addq.l	#8,SP
		rts

fsnext: 	move.w	#$4F,-(SP)
		bsr	gemdos
		addq.l	#2,SP
		rts

frename:	move.l	A0,-(SP)
		move.l	A1,-(SP)
		pea	$560000
		bsr	gemdos
		lea	12(SP),SP
		rts

fdatime:	move.w	D0,-(SP)
		move.w	D7,-(SP)
		move.w	D1,-(SP)
		move.w	#$57,-(SP)
		bsr	gemdos
		lea	10(SP),SP
		rts

;************************************************************************
;* Allgemeiner Gemdos-Einsprung, welcher alle Register rettet (auûer D0)*
;* ACHTUNG! Sonst kînnten die Register D0-D4/A0-A4 zerstîrt werden.	*
;************************************************************************
gemdos: 	move.l	A0,D0
		lea	regsave(PC),A0
		movem.l D0-D7/A1-A7,(A0)
		move.l	(SP)+,-(A0)	;RÅcksprungadr retten
		trap	#1
		movea.l D0,A0		;Fehlermeldung retten
		movem.l regsave(PC),D0-D7/A1-A7
		exg	A0,D0
		move.l	retsave(PC),(SP)
		rts

retsave:	DS.L 1
regsave:	DS.L 15
