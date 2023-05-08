;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|				Plotsy - bajerek z paroma tysiacami punktow	  			  |
;|  																	  |
;| autor: Van Eijk, 								    				  |	
;| uwagi: -	Ktos mi kiedys zarzucil, ze to jest zrobione rotajca kolorow, |
;|          to jednak nie jest pradwa.									  |
;|			Obliczonych jest pare torow, trzyba tylko w Incbin zmienic 	  |
;|			nazwe pliku 4.VVE na 1.VVE lub 2.VVE itd od 1 do 5.			  |
;*------------------------------------------------------------------------*


EKRAN:	equ		$78000+320000


START: 	clr.l 	-(sP)
		move.w 	#32,-(SP)
		trap 	#1
		addq.l 	#6,SP	

		move.w	#0,-(sp)
	    move.l	#EKRAN,-(sp)
	    move.l	#EKRAN,-(sp)
	    move.w 	#5,-(a7)                
    	trap 	#14                       
	    adda.l 	#12,a7  

		move.l	#EKRAN,a0
		move.w	#232*40-1,d0
NM:		clr.l	(a0)+
		dbf		d0,NM

		move.b 	#$12,$ffffc02

*-------------------------------------------------------------------------*

		move.w	#$0,$fff8240
		move.w	#$0,$fff8242
		move.w	#$0,$fff8244
		move.w	#$0,$fff8246
		move.w	#$0,$fff8248
		move.w	#$0,$fff824a
		move.w	#$0,$fff824c
		move.w	#$0,$fff824e
		move.w	#$0,$fff8250
		move.w	#$0,$fff8252
		move.w	#$0,$fff8254
		move.w	#$0,$fff8256
		move.w	#$0,$fff8258
		move.w	#$0,$fff825a
		move.w	#$0,$fff825c
		move.w	#$0,$fff825e

		move.l	#KOLOR,LEKOLOR
		move.w	#3,NR
		move.w	#0,CZEKAJ
		move.w	#0,C1
		move.w	#0,C2
		move.w	#-1,WAR1

		jsr		INIT

*-------------------------------------------------------------------------*

		move.l 	#SAFEREG,a0
		move.b 	$fffa07,(a0)+
		move.b 	$fffa09,(a0)+
		move.b 	$fffa13,(a0)+
		move.b 	$fffa17,(a0)+
		move.b 	$fffa19,(a0)+
		move.b 	$fffa1f,(a0)+
		move.b 	$fffa1b,(a0)+
		move.b 	$fffa21,(a0)+
		move.l 	$70,OLD_VBL
		move.l 	$120,OLD_TIMERB
		move.l	$134,OLD_TIMERA

*-------------------------------------------------------------------------*

		move.b #8,$fffa1b
		move.b #4,$fffa21
		andi.b #%11011111,$fffa09
		clr.b  $fffffa19
		move.b #$21,$fffffa07
		move.b #$21,$fffffa13
		bclr   #3,$fffffa17
		move.l #VBL,$70
		move.l #TIMER_B,$120
		move.l #TIMER_A,$134
		move.w #$2300,sr		

*-------------------------------------------------------------------------*

LOOP:	bra		LOOP

*-------------------------------------------------------------------------*

VBL:	clr.b	$fffffa19
		move.b	#100,$fffffa1f	
		move.b	#4,$fffffa19	
		clr.b	$fffffa1b		
		move.b	#228,$fffffa21	
		move.l	#TIMER_B,$120	
		move.b	#8,$fffffa1b	

		cmp.w 	#3,WAR1
		beq 	END
		cmp.b 	#57,$ffffc02
		beq 	END

		jsr		WEKTOR
		movem.l	a0-a1/d0-d4,-(sp)
		jsr		PONIES
		movem.l	(sp)+,a0-a1/d0-d4
		rte

*-------------------------------------------------------------------------*

PONIES:	cmp.w	#999,WAR1
		beq		TU3
		cmp.w	#1,WAR1
		beq		TU0
		cmp.w	#2,WAR1
		bne		TU9
		jsr		IBM
		bra		TU3
TU9:	cmp.w	#0,NR
		bne		TU4
		move.w	#1,d1
TU4:	cmp.w	#1,NR
		bne		TU5
		move.w	#16,d1
TU5:	cmp.w	#2,NR
		bne		TU6
		move.w	#256,d1
TU6:	cmp.w	#3,NR
		bne		TU7
		move.w	#257,d1
TU7:	move.l	LEKOLOR,a0
		cmp.w	#999,(a0)
		bne		TU1
		move.w	#1,WAR1
		bra		TU0
TU1:	clr.w	d2
		clr.w	d3
		move.w	(a0)+,d2
		move.w	(a0)+,d3
		mulu.w	d1,d2
		mulu.w	d1,d3
		move.w	d2,C1
		move.w	d3,C2
		move.l	a0,LEKOLOR				
TU2:	bra		TU3
TU0:	add.w	#1,CZEKAJ
		cmp.w	#1000,CZEKAJ
		bne		TU3
		move.w	#0,CZEKAJ
		move.w	#2,WAR1
		move.l	#KOLOR,LEKOLOR
		move.l	#KOLOR1,LEKOLOR1
TU3:	rts

*-------------------------------------------------------------------------*

IBM:	cmp.w	#0,NR
		bne		TUS4
		move.w	#1,d1
TUS4:	cmp.w	#1,NR
		bne		TUS5
		move.w	#16,d1
TUS5:	cmp.w	#2,NR
		bne		TUS6
		move.w	#256,d1
TUS6:	cmp.w	#3,NR
		bne		TUS7
		move.w	#257,d1
TUS7:	move.l	LEKOLOR1,a0
		cmp.w	#999,(a0)
		bne		TUS1
		move.w	#2,WAR1
		bra		TUS0
TUS1:	clr.w	d2
		clr.w	d3
		move.w	(a0)+,d2
		move.w	(a0)+,d3
		mulu.w	d1,d2
		mulu.w	d1,d3
		move.w	d2,C2
		move.w	d3,C1
		move.l	a0,LEKOLOR1				
		bra		TUS3
TUS0:	move.w	#3,WAR1
		move.l	#KOLOR1,LEKOLOR1
TUS3:	rts

*-------------------------------------------------------------------------*

TIMER_B:move.w	d0,-(sp)		
		rept	32		
		nop
		endr			
		clr.w	d0		
		move.b	$ffff8209,d0	
		neg.b	d0		
		add.b	#192,d0		
		lsl.b	d0,d0		
		move.w	#18,d0		
PAUSE:	dbra	d0,PAUSE		
		move.b	#0,$ffff820a	
		rept	12		
		nop
		endr			
		move.b	#2,$ffff820a	
		move.w	#1300,d0
SK:		nop
		dbf		d0,SK
		move.w	(sp)+,d0		
		move.w	C1,$fff8244
		move.w	C2,$fff8246
		move.w	C2,$fff8248
		move.w	C2,$fff824a
		move.w	C1,$fff824c
		move.w	C1,$fff824e
		move.w	C1,$fff8250
		move.w	C1,$fff8252
		move.w	C1,$fff8254
		move.w	C1,$fff8256
		move.w	C1,$fff8258
		move.w	C1,$fff825a
		move.w	C1,$fff825c
		move.w	C1,$fff825e
		rte

*-------------------------------------------------------------------------*

TIMER_A	move.w	#$2100,sr
		stop	#$2100		
		clr.b	$fffffa19	
		rept	78		
		nop
		endr			
		clr.b	$ffff820a
		nop
		nop
		move.b	#2,$ffff820a
		rte

*-------------------------------------------------------------------------*

END:	move.w	#$2700,SR
		move.l 	OLD_VBL,$70
		move.l 	OLD_TIMERB,$120
		move.l 	OLD_TIMERA,$134
		move.l 	#SAFEREG,a0
		move.b 	(a0)+,$fffa07
		move.b 	(a0)+,$fffa09
		move.b 	(a0)+,$fffa13
		move.b 	(a0)+,$fffa17
		move.b 	(a0)+,$fffa19	
		move.b 	(a0)+,$fffa1f	
		move.b 	(a0)+,$fffa1b
		move.b 	(a0)+,$fffa21
		move.w	#$2300,SR
		move.w	#$000,$ffff8246
		move.w	#$fff,$ffff8240
		move.b	#8,$ffffc02
		clr.l	-(sp)
		trap	#1
		rts

*-------------------------------------------------------------------------*

CZYSC:	move.l #EKRAN,a0
		move.w #300*40,d0
SPA:	clr.l 	(a0)+
		dbf 	d0,SPA
		rts
	
INIT:	jsr		CZYSC
		move.l	#DAT1+000*100,DANE0
		move.l	#DAT1+025*100,DANE1
		move.l	#DAT1+062*100,DANE2
		move.l	#DAT1+087*100,DANE3
		move.l	#DAT1+124*100,DANE4
		move.l	#DAT1+149*100,DANE5
		move.l	#DAT1+186*100,DANE6
		move.l	#DAT1+211*100,DANE7
		move.l	#DAT1+248*100,DANE8
		move.l	#DAT1+273*100,DANE9
		move.l	#DAT1,a0
		move.w	#((3150/2)*5),d0
OKL:	move.l	#EKRAN+2,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bset	d1,(a1)
		dbf		d0,OKL
		rept	26
		jsr		WEKTOR
		endr
		rts

*-------------------------------------------------------------------------*

WEKTOR:	movem.l	a0-a1/d0-d2,-(sp)
		jsr		RYS0 
		jsr		RYS1
		jsr		RYS2
		jsr		RYS3
		jsr		RYS4
		jsr		RYS5
		jsr		RYS6
		jsr		RYS7
		jsr		RYS8
		jsr		RYS9
		movem.l	(sp)+,a0-a1/d0-d2
		rts
RYS1:	move.l	DANE1,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL1
		move.l	#DAT1,DANE1
		move.l	DANE1,a0
		bra		RTS1
DAL1:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bset	d1,(a1)
		dbf		d0,DAL1		
		move.l	a0,DANE1
RTS1:	rts	
RYS0:	move.l	DANE0,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL0
		move.l	#DAT1,DANE0
		move.l	DANE0,a0
		bra		RTS0
DAL0:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bclr	d1,(a1)
		dbf		d0,DAL0		
		move.l	a0,DANE0
RTS0:	rts	
RYS3:	move.l	DANE3,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL3
		move.l	#DAT1,DANE3
		move.l	DANE3,a0
		bra		RTS3
DAL3:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bset	d1,(a1)
		dbf		d0,DAL3
		move.l	a0,DANE3
RTS3:	rts	
RYS2:	move.l	DANE2,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL2
		move.l	#DAT1,DANE2
		move.l	DANE2,a0
		bra		RTS2
DAL2:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bclr	d1,(a1)
		dbf		d0,DAL2
		move.l	a0,DANE2
RTS2:	rts	
RYS5:	move.l	DANE5,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL5
		move.l	#DAT1,DANE5
		move.l	DANE5,a0
		bra		RTS5
DAL5:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bset	d1,(a1)
		dbf		d0,DAL5
		move.l	a0,DANE5
RTS5:	rts	
RYS4:	move.l	DANE4,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL4
		move.l	#DAT1,DANE4
		move.l	DANE4,a0
		bra		RTS4
DAL4:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bclr	d1,(a1)
		dbf		d0,DAL4
		move.l	a0,DANE4
RTS4:	rts	
RYS7:	move.l	DANE7,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL7
		move.l	#DAT1,DANE7
		move.l	DANE7,a0
		bra		RTS7
DAL7:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bset	d1,(a1)
		dbf		d0,DAL7
		move.l	a0,DANE7
RTS7:	rts	
RYS6:	move.l	DANE6,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL6
		move.l	#DAT1,DANE6
		move.l	DANE6,a0
		bra		RTS6
DAL6:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bclr	d1,(a1)
		dbf		d0,DAL6
		move.l	a0,DANE6
RTS6:	rts	
RYS9:	move.l	DANE9,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL9
		move.l	#DAT1,DANE9
		move.l	DANE9,a0
		bra		RTS9
DAL9:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bset	d1,(a1)
		dbf		d0,DAL9
		move.l	a0,DANE9
RTS9:	rts	
RYS8:	move.l	DANE8,a0
		move.w	#49,d0
		cmp.w	#999,(a0)
		bne 	DAL8
		move.l	#DAT1,DANE8
		move.l	DANE8,a0
		bra		RTS8
DAL8:	move.l	#EKRAN,a1
		move.w	(a0)+,d2
		add.l	d2,a1
		move.w	(a0)+,d1
		bclr	d1,(a1)
		dbf		d0,DAL8
		move.l	a0,DANE8
RTS8:	rts	

*-------------------------------------------------------------------------*

OLD:			dc.l	1
				even
OLD_VBL:		ds.l 	1
				even
OLD_TIMERB: 	ds.l 	1
				even
OLD_TIMERA: 	ds.l 	1
				even
SAFEREG: 		ds.b 	14
				even
KOLOR:			dc.w	$8,$8,$8,$8,$1,$1,$1,$1,$9,$9,$9,$9,$2,$2,$2,$2,$2,$a,$2,$a,$2,$3,$2,$3,$2,$b,$2,$b,$2,$4,$2,$4,$2,$c,$2,$c,$2,$5,$2,$5,$2,$d,$2,$d,$2,$6,$2,$6,$2,$e,$2,$e,$2,$7,$2,$7,$2,$f,$2,$f,$2,$f
				dc.w	999,999
				even
KOLOR1:			dc.w	$f,2,$f,2,$7,2,$7,2,$e,2,$e,2,$6,2,$6,2,$d,2,$d,2,$5,2,$5,2,$c,2,$c,2,$4,2,$4,2,$b,2,$b,2,$3,2,$3,2,$a,2,$a,2,$2,2,$2,2,$9,9,$9,9,$1,1,$1,1,$8,8,$8,8,0,0,999
				even
WAR1:			dc.w	1
				even
NR:				dc.w	1
				even
C1:				dc.w	1
				even
C2:				dc.w	1
				even
LEKOLOR:		dc.l	1
				even
LEKOLOR1:		dc.l	1
				even
CZEKAJ:			dc.w	1
				even

*-------------------------------------------------------------------------*

DAT1:			incbin	"\asembler.s\dane.dat\4.vve"
				dc.w	999,999,999,999,999,999,999,999,999,999
				dc.w	999,999,999,999,999,999,999,999,999,999
				dc.w	999,999,999,999,999,999,999,999,999,999
				dc.w	999,999,999,999,999,999,999,999,999,999
				dc.w	999,999,999,999,999,999,999,999,999,999
				dc.w	999,999,999,999,999,999,999,999,999,999
				dc.w	999,999,999,999,999,999,999,999,999,999
				dc.w	999,999,999,999,999,999,999,999,999,999
				dc.w	999,999,999,999,999,999,999,999,999,999
				dc.w	999,999,999,999,999,999,999,999,999,999
				even
DANE0:			dc.l	1000
				even
DANE1:			dc.l	1000	
				even
DANE2:			dc.l	1000
				even
DANE3:			dc.l	1000	
				even
DANE4:			dc.l	1000
				even
DANE5:			dc.l	1000	
				even
DANE6:			dc.l	1000
				even
DANE7:			dc.l	1000	
				even
DANE8:			dc.l	1000
				even
DANE9:			dc.l	1000	
				even
