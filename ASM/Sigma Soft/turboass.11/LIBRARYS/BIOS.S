;************************************************************************
;* BIOS-Library, öbergabe in Registern					*
;* Ω1989 by ‰-soft, written by Markus Fritze	       18.06.1988 01:59 *
;************************************************************************

getmpb: 	move.l	A0,-(SP)
		clr.w	-(SP)
		bsr	bios
		addq.l	#6,SP
		rts

bconstat:	move.w	D0,-(SP)
		move.w	#1,-(SP)
		bsr	bios
		addq.l	#4,SP
		rts

bconin: 	move.w	D0,-(SP)
		move.w	#2,-(SP)
		bsr	bios
		addq.l	#4,SP
		rts

bconout:	move.w	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#3,-(SP)
		bsr	bios
		addq.l	#6,SP
		rts

rwabs:		move.w	D0,-(SP)
		move.w	D1,-(SP)
		move.w	D2,-(SP)
		move.l	A0,-(SP)
		move.w	D3,-(SP)
		move.w	#4,-(SP)
		bsr	bios
		lea	14(SP),SP
		rts

setexc: 	move.l	A0,-(SP)
		move.w	D0,-(SP)
		move.w	#5,-(SP)
		bsr	bios
		addq.l	#8,SP
		rts

tickcal:	move.w	#6,-(SP)
		bsr	bios
		addq.l	#2,SP
		rts

getbpb: 	move.w	D0,-(SP)
		move.w	#7,-(SP)
		bsr	bios
		addq.l	#4,SP
		rts

bcostat:	move.w	D0,-(SP)
		move.w	#8,-(SP)
		bsr	bios
		addq.l	#4,SP
		rts

mediach:	move.w	D0,-(SP)
		move.w	#9,-(SP)
		bsr	bios
		addq.l	#4,SP
		rts

drvmap: 	move.w	#$0A,-(SP)
		bsr	bios
		addq.l	#2,SP
		rts

kbshift:	move.w	D0,-(SP)
		move.w	#$0B,-(SP)
		bsr	bios
		addq.l	#4,SP
		rts

;************************************************************************
;* Allgemeiner Bios-Einsprung, welcher alle Register rettet (auûer D0)	*
;* ACHTUNG! Sonst kînnten die Register D0-D2/A0-A2 zerstîrt werden	*
;************************************************************************
bios:		move.l	A0,D0
		lea	regsave(PC),A0
		movem.l D0-D7/A1-A7,(A0)
		move.l	(SP)+,-(A0)	;RÅcksprungadr retten
		trap	#13
		movea.l D0,A0		;Fehlermeldung retten
		movem.l regsave(PC),D0-D7/A1-A7
		exg	A0,D0
		move.l	retsave(PC),(SP)
		rts

retsave:	DS.L 1
regsave:	DS.L 15
