***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Show - efektowne (?!) pokazanie sie rysunku               *
* autor      :  Van Eijk                                                  *
* inne uwagi :  320x200 !!!                                               *
***************************************************************************

		clr.l -(sp)
		move.w #$20,-(sp)
		trap #1
		addq.l #6,-(sp)

		move.l	#RYS+2,-(sp)
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp

		move.w	#0,-(sp)
		move.l 	#$78000,-(sp)
		move.l 	#$78000,-(sp)
		move.w 	#5,-(sp)
		trap 	#14
		add.l 	#12,sp

		move.l	#$78000,a0
		move.w	#200*40,d0
CLER:	clr.l	(a0)+
		dbf		d0,CLER


		move.w	#0,LC
		move.w	#0,KLT
		move.l 	$70,OLDVBL
		move.l 	#VBL,$70.w	

LOOP:	bra		LOOP


END:	move.l 	OLDVBL,$70
		move.w	#$fff,$fff8240
		move.w	#0,$fff8246
		move.b	#255,$484
		clr.l	-(sp)
		trap	#1
		rts

*-------------------------------------------------------------------------*

VBL:	cmp.b	#57,$fffc02
		beq		END
		jsr		OBKRECAJ
		rte

*-------------------------------------------------------------------------*

OBKRECAJ:
		movem.l	a0-a2/d0-d1,-(sp)

		cmp.w	#32,KLT
		bEQ		RTS1

		cmp.w	#29,LC
		beq		KLAPA

		move.l	#RYS+34,a1
		move.l	#TOR,a2
		move.l	#TAB,a3

		add.w	KLT,a3
		add.w	(a3),a1
		clr.w	d0

		move.w	LC,d0
		mulu.w	#50*2,d0
		add.w	d0,a2
		add.w	#1,LC
		clr.w	d0

		move.w	#49,d0
ZU1:	move.l	#$78000,a0
		move.l	#TAB,a3
		add.w	KLT,a3
		add.w	(a3),a0
		add.w	(a2)+,a0
		move.w	#9,d1
ZU2:	move.l	(a1)+,(a0)+
		dbf		d1,ZU2		
		add.w	#120,a1
		dbf		d0,ZU1
		bra		RTS1
KLAPA:	add.w	#2,KLT		
		move.w	#0,LC
RTS1:	movem.l	(sp)+,a0-a2/d0-d1
		RTS

*-------------------------------------------------------------------------*

TAB:	dc.w	000*160+000
		dc.w	100*160+040
		dc.w	000*160+080
		dc.w	150*160+120
		dc.w	000*160+120
		dc.w	050*160+000
		dc.w	100*160+080
		dc.w	150*160+040
		dc.w	100*160+120
		dc.w	050*160+080
		dc.w	100*160+000
		dc.w	000*160+040
		dc.w	150*160+000
		dc.w	050*160+120
		dc.w	150*160+080
		dc.w	050*160+040
		even
KLT:	dc.w	1
		even
LC:		dc.w	1
		even
TOR:	incbin	"A:ASEMBLER.S\DANE.DAT.PI1\OBROT.DAT"
		even
RYS:	incbin	"A:ASEMBLER.S\DANE.DAT.PI1\MOTOR.PI1"
		even
OLDVBL:	dc.l	1
		even