;************************************************************************
;* XBIOS-Library, öbergabe in Registern 				*
;* Ω1989 by ‰-soft, written by Markus Fritze	       18.06.1988 02:20 *
;************************************************************************

initmous:	move.l	A0,-(SP)
		move.l	A1,-(SP)
		move.w	D0,-(SP)
		clr.w	-(SP)
		bsr	xbios
		lea	12(SP),SP
		rts

ssbrk:		move.w	D0,-(SP)
		move.w	#1,-(SP)
		bsr	xbios
		addq.l	#4,SP
		rts

physbase:	move.w	#2,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

logbase:	move.w	#3,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

getrez: 	move.w	#4,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

setscreen:	move.w	D0,-(SP)
		move.l	A0,-(SP)
		move.l	A1,-(SP)
		move.w	#5,-(SP)
		bsr	xbios
		lea	12(SP),SP
		rts

setpalette:	move.l	A0,-(SP)
		move.w	#6,-(SP)
		bsr	xbios
		addq.l	#6,SP
		rts

setcolor:	move.w	D0,-(SP)
		move.w	D1,-(SP)
		bsr	xbios
		addq.l	#4,SP
		rts

floprd: 	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	D2,-(SP)
		move.w	D3,-(SP)
		move.w	D4,-(SP)
		clr.l	-(SP)
		move.l	A0,-(SP)
		move.w	#8,-(SP)
		bsr	xbios
		lea	20(SP),SP
		rts

flopwr: 	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	D2,-(SP)
		move.w	D3,-(SP)
		move.w	D4,-(SP)
		clr.l	-(SP)
		move.l	A0,-(SP)
		move.w	#9,-(SP)
		bsr	xbios
		lea	20(SP),SP
		rts

flopmt: 	move.w	D0,-(SP)
		move.l	D1,-(SP)
		move.w	D2,-(SP)
		move.w	D3,-(SP)
		move.w	D4,-(SP)
		move.w	D5,-(SP)
		move.w	D6,-(SP)
		move.l	A1,-(SP)
		move.l	A0,-(SP)
		move.w	#$0A,-(SP)
		bsr	xbios
		lea	26(SP),SP
		rts

getdsb: 	move.w	#$0B,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

midiws: 	move.l	A0,-(SP)
		move.w	D0,-(SP)
		move.w	#$0C,-(SP)
		bsr	xbios
		addq.l	#8,SP
		rts

mfpint: 	move.l	A0,-(SP)
		move.w	D0,-(SP)
		move.w	#$0D,-(SP)
		bsr	xbios
		addq.l	#8,SP
		rts

iorec:		move.w	D0,-(SP)
		move.w	#$0E,-(SP)
		bsr	xbios
		addq.l	#4,SP
		rts

rsconf: 	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	D2,-(SP)
		move.w	D3,-(SP)
		move.w	D4,-(SP)
		move.w	D5,-(SP)
		move.w	#$0F,-(SP)
		bsr	xbios
		lea	14(SP),SP
		rts

keytbl: 	move.l	A0,-(SP)
		move.l	A1,-(SP)
		move.l	A2,-(SP)
		move.w	#$10,-(SP)
		bsr	xbios
		lea	14(SP),SP
		rts

random: 	move.w	#$11,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

protobt:	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.l	D2,-(SP)
		move.l	A0,-(SP)
		move.w	#$12,-(SP)
		bsr	xbios
		lea	14(SP),SP
		rts

flopver:	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	D2,-(SP)
		move.w	D3,-(SP)
		move.w	D4,-(SP)
		clr.l	-(SP)
		move.l	A0,-(SP)
		move.w	#$13,-(SP)
		bsr	xbios
		lea	20(SP),SP
		rts

scrdmp: 	move.w	#$14,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

cursconf:	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	#$15,-(SP)
		bsr	xbios
		addq.l	#6,SP
		rts

settime:	move.l	D0,-(SP)
		move.w	#$16,-(SP)
		bsr	xbios
		addq.l	#6,SP
		rts

gettime:	move.w	#$17,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

bioskeys:	move.w	#$18,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

ikbdws: 	move.l	A0,-(SP)
		move.w	D0,-(SP)
		move.w	#$19,-(SP)
		bsr	xbios
		addq.l	#8,SP
		rts

jdisint:	move.w	D0,-(SP)
		move.w	#$1A,-(SP)
		bsr	xbios
		addq.l	#4,SP
		rts

jenabint:	move.w	D0,-(SP)
		move.w	#$1B,-(SP)
		bsr	xbios
		addq.l	#4,SP
		rts

giaccess:	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	#$1C,-(SP)
		bsr	xbios
		addq.l	#6,SP
		rts

offgibit:	move.w	D0,-(SP)
		move.w	#$1D,-(SP)
		bsr	xbios
		addq.l	#4,SP
		rts

ongibit:	move.w	D0,-(SP)
		move.w	#$1E,-(SP)
		bsr	xbios
		addq.l	#4,SP
		rts

xbtimer:	move.l	A0,-(SP)
		move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	D2,-(SP)
		move.w	#$1F,-(SP)
		bsr	xbios
		lea	12(SP),SP
		rts

dosound:	move.l	A0,-(SP)
		move.w	#$20,-(SP)
		bsr	xbios
		addq.l	#6,SP
		rts

setprt: 	move.w	D0,-(SP)
		move.w	#$21,-(SP)
		bsr	xbios
		addq.l	#4,SP
		rts

kbdvbase:	move.w	#$22,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

kbrate: 	move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	#$23,-(SP)
		bsr	xbios
		addq.l	#6,SP
		rts

prtblk: 	move.l	A0,-(SP)
		move.w	#$24,-(SP)
		bsr	xbios
		addq.l	#6,SP
		rts

vsync:		move.w	#$25,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

supexec:	move.l	A0,-(SP)
		move.w	#$26,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

puntaes:	move.w	#$27,-(SP)
		bsr	xbios
		addq.l	#2,SP
		rts

blitmode:	move.w	D0,-(SP)
		move.w	#$40,-(SP)
		bsr	xbios
		addq.l	#4,SP
		rts

;************************************************************************
;* Allgemeiner Xbios-Einsprung, welcher alle Register rettet (auûer D0) *
;* ACHTUNG! Sonst kînnten die Register D0-D2/A0-A2 zerstîrt werden	*
;************************************************************************
xbios:		move.l	A0,D0
		lea	regsave(PC),A0
		movem.l D0-D7/A1-A7,(A0)
		move.l	(SP)+,-(A0)	;RÅcksprungadr retten
		trap	#14
		movea.l D0,A0		;Fehlermeldung retten
		movem.l regsave(PC),D0-D7/A1-A7
		exg	A0,D0
		move.l	retsave(PC),(SP)
		rts

retsave:	DS.L 1
regsave:	DS.L 15

