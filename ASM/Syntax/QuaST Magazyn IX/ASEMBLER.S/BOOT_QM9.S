;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|      Boot sector QM 9 - Program nagrywajacy bootsector QuaST Maga 9    |
;|  																	  |
;| autor: Van Eijk														  |
;| uwagi: - 															  |
;*------------------------------------------------------------------------*

			opt	x+

START:
			clr.l	-(sp)
			move.w	#32,-(sp)
			trap	#1
			addq.l	#6,sp

			move.w	#1,-(sp)
			move.w	#0,-(sp)
			move.w	#0,-(sp)
			move.w	#1,-(sp)
			move.w	#0,-(sp)
			clr.l	-(sp)
			move.l	#BUFOR,-(sp)
			move.w	#8,-(sp)
			trap	#14
			add.w	#20,sp

ADRES		equ	30

			move.l	#510,d0
			move.l	#TEKST,a0
			move.l	#BUFOR,a1
			move.w	#$6000+ADRES-2,(a1)
			adda.l	#ADRES,a1
COPY_COPY:	move.b	(a0)+,(a1)+
			dbf	d0,COPY_COPY	

			clr.l	d1
			lea		BUFOR,a0
			move.w	#255,d0
PETLA:		add.w	(a0)+,d1
			dbf		d0,PETLA

			andi.l	#$ffff,d1
			clr.l	d0

BUDOWA_SUMY:cmp.w	#$1234,d1
			beq		JEST_SUMA

			add.l	#1,d0
			add.l	#1,d1
			bra		BUDOWA_SUMY

JEST_SUMA:	move.l	#BUFOR,a0
			move.w	d0,510(a0)

			move.w	#1,-(sp)
			move.w	#0,-(sp)
			move.w	#0,-(sp)
			move.w	#1,-(sp)
			move.w	#0,-(sp)
			clr.l	-(sp)
			move.l	#BUFOR,-(sp)
			move.w	#9,-(sp)
			trap	#14
			add.w	#20,sp

			clr.w	-(sp)
			trap	#1

BUFOR:		ds.b	512

TEKST:		move.b	#0,$484				* glowny program bootsectora
			move.b	#18,$fffc02

			move.w	#0,$fff8240
			move.w	#$fff,$fff8242

			move.l	$44e,a0
			add.w	#72*160,a0
			lea		boot(pc),a1
			moveq	#53,d0

KL:			move.w	(a1)+,64(a0)
			move.w	(a1)+,72(a0)
			move.w	(a1)+,80(a0)
			add.w	#160,a0
			dbf		d0,KL
			rts

boot:		incbin	"\asembler.s\dane.dat\boot.dat"
			even

*-------------------------------------------------------------------------*

WYPELNIENIE:ds.b	512
