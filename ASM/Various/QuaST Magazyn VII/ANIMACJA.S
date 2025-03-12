***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Animacja na 3 bitplanach - 2,3,4 - 1 wolny                *
* autor      :  Van Eijk                                                  *
* inne uwagi :  320x200 !!!                                               *
***************************************************************************

START:	clr.l	-(sp)				* Wywolanie trybu Supervisor !!!,
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

	    clr.w 	-(a7)                    
    	pea 	$78000              * niska rozdzielczosc
	    pea 	$78000                     
    	move.w 	#5,-(a7)                
	    trap 	#14                       
    	adda.l 	#12,a7  

		move.b	#18,$fffc02
		move.l 	#$78000,a0			* czyszczenie ekranu
		move.w 	#280*40-1,d0
SPRZ:	clr.l 	(a0)+
		dbf 	d0,SPRZ

		jsr		INIT_MED

		move.l #SAFEREG,a0			* zapamietanie rejestrow MFP
		move.b $fffa07,(a0)+
		move.b $fffa09,(a0)+
		move.b $fffa0b,(a0)+
		move.b $fffa0f,(a0)+
		move.b $fffa13,(a0)+
		move.b $fffa17,(a0)+
		move.b $fffa19,(a0)+	
		move.b $fffa1f,(a0)+	
		move.b $fffa1b,(a0)+
		move.b $fffa1d,(a0)+		
		move.b $fffa21,(a0)+
		move.l $120,OLD_TIMERB		* zapamietanie starego TIMERA B
		move.l $134,OLD_TIMERA    	* zapamietanie starego TIMERA A
		move.l $70,OLD_VBL			* zapamietanie VBLa
	
		andi.b 	#%11011111,$fffa09
		move.b 	#$21,$fffffa07	
		move.b 	#$21,$fffffa13	
		bclr	#3,$ffffa17

		move.l  #VBL,$70.w           * nowa procedura dla VBLa
		move.l  #TIMER_B,$120        *     --//--     dla TIMERA B
		move.l  #TIMER_A,$134        *     --//--     dla TIMERA A
		move.w  #$2300,sr		

*-------------------------------------------------------------------------*

PRG:	bra		PRG		              * petla,

*-------------------------------------------------------------------------*

END:
		move.l 	OLD_VBL,$70			* zwrocenie starych wartosci przerwan 
		move.l 	OLD_TIMERB,$120		*  VBL'a,TIMERa B i TOMERa A,
		move.l 	OLD_TIMERA,$134

		move.l 	#SAFEREG,a0			* zwrocenie starych wartosci timerow,
		move.b 	(a0)+,$fffa07
		move.b 	(a0)+,$fffa09
		move.b 	(a0)+,$fffa0b                              
		move.b 	(a0)+,$fffa0f
		move.b 	(a0)+,$fffa13
		move.b 	(a0)+,$fffa17
		move.b 	(a0)+,$fffa19	
		move.b 	(a0)+,$fffa1f	
		move.b 	(a0)+,$fffa1b
		move.b 	(a0)+,$fffa1d
		move.b 	(a0)+,$fffa21
		move.b 	#$f7,$fffa23

		move.w	#0,$fff8246
		move.w	#$fff,$fff8240
		move.b	#8,$fffc02
		clr.l	-(sp)
		trap	#1
		rts

*-------------------------------------------------------------------------*

VBL:								* procedura VBLa,
		clr.b	$fffffa1b	
		move.b	#228,$fffffa21
		move.l	#TIMER_B,$120		* Timer B usuwa dolna ramke,
		move.b	#8,$fffffa1b

		clr.b	$fffffa19			* Timer A usuwa gorna ramke,
		move.b	#100,$fffffa1f		
		move.b	#4,$fffffa19	

		cmp.b	#57,$fffc02
		beq		END

		jsr		LOT_MEDUZY			* skok do glownej procedury,

		rte

*-------------------------------------------------------------------------*

TIMER_B:						* procedura przerwania TIMERa B
		move.w	#0,$fff8240
		move.w	d0,-(sp)		
		rept	32
		nop			nop 
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
		nop			nop 
		endr			
		move.b	#2,$ffff820a	
		move.w	(sp)+,d0		
		rte

TIMER_A	
		move.w	#$2100,sr		* procedura przerwania TIMERa A
		stop	#$2100		
		clr.b	$fffffa19	
		rept	78		
		nop			nop 
		endr			
		clr.b	$ffff820a
		nop			nop
		nop			nop 
		move.b	#2,$ffff820a	
		rte			

OLD_TIMERB: 	ds.l 1
OLD_TIMERA: 	ds.l 1
OLD_VBL: 		ds.l 1
SAFEREG: 		ds.b 12
				even

*-------------------------------------------------------------------------*

INIT_MED:
		move.w	#1,CMD
		move.w	#2,CMD1
		move.w	#3,CMD2
		move.w	#0,CMD3
		move.w	#0,NMD
		move.w	#230,YMD
		move.w	#5,NMD1
		move.w	#200,YMD1
		move.w	#2,NMD2
		move.w	#300,YMD2
		move.w	#6,NMD3
		move.w	#51,YMD3
		move.w	#1,NMD4
		move.w	#150,YMD4
		move.w	#7,NMD5
		move.w	#250,YMD5
		move.w	#3,NMD6
		move.w	#-30,YMD6
		move.w	#5,NMD7
		move.w	#64,YMD7
		move.w	#1,NMD8
		move.w	#14,YMD8
		move.w	#0,NMD9
		move.w	#190,YMD9

		move.w	#$000,$fff8240
		move.w	#$111,$fff8244
		move.w	#$222,$fff8248
		move.w	#$333,$fff824c
		move.w	#$444,$fff8250
		move.w	#$555,$fff8254
		move.w	#$666,$fff8258
		move.w	#$777,$fff825c
		rts

*-------------------------------------------------------------------------*

LOT_MEDUZY:
		movem.l	d0-d7/a0-a6,-(sp)
		jsr		LOT1
		jsr		LOT2
		jsr		LOT3
		jsr		LOT4
		movem.l	(sp)+,d0-d7/a0-a6
		rts	
LOT1:	add.w	#1,CMD
		cmp.w	#1,CMD
		beq		MEDUZA0
		cmp.w	#2,CMD
		beq		MEDUZA1
		cmp.w	#3,CMD
		beq		MEDUZA2
		cmp.w	#4,CMD
		bne		HHHH1
		move.w	#0,CMD
HHHH1:	rts
LOT2:	add.w	#1,CMD1
		cmp.w	#1,CMD1
		beq		MEDUZA3
		cmp.w	#2,CMD1
		beq		MEDUZA4
		cmp.w	#3,CMD1
		beq		MEDUZA5
		cmp.w	#4,CMD1
		bne		HHHH2
		move.w	#0,CMD1
HHHH2:	rts
LOT3:	add.w	#1,CMD2
		cmp.w	#1,CMD2
		beq		MEDUZA6
		cmp.w	#2,CMD2
		beq		MEDUZA7
		cmp.w	#3,CMD2
		beq		MEDUZA8
		cmp.w	#4,CMD2
		bne		HHHH3
		move.w	#0,CMD2
HHHH3:	rts
LOT4:	add.w	#1,CMD3
		cmp.w	#4,CMD3
		bne		HHHH4
		move.w	#0,CMD3
		jsr		MEDUZA9
HHHH4:	rts
MEDUZA0:
		add.w	#1,NMD
		cmp.w	#8,NMD
		bne		MD0
		move.w	#0,NMD
MD0:	sub.w	#1,YMD
		cmp.w	#-108,YMD
		bne		MD1
		move.w	#300,YMD
MD1:	move.l	#MED,a1
		move.w	NMD,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8000+3200,a0
		clr.w	d1
		move.w	YMD,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD2:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD2
		rts
MEDUZA1:
		add.w	#1,NMD1
		cmp.w	#8,NMD1
		bne		MD01
		move.w	#0,NMD1
MD01:	sub.w	#1,YMD1
		cmp.w	#-108,YMD1
		bne		MD11
		move.w	#300,YMD1
MD11:	move.l	#MED,a1
		move.w	NMD1,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8016+3200,a0
		move.w	YMD1,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD21:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD21
		rts
MEDUZA2:
		add.w	#1,NMD2
		cmp.w	#8,NMD2
		bne		MD02
		move.w	#0,NMD2
MD02:	sub.w	#3,YMD2
		cmp.w	#-108,YMD2
		bne		MD12
		move.w	#300,YMD2
MD12:	move.l	#MED,a1
		move.w	NMD2,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8032+3200,a0
		move.w	YMD2,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD22:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD22
		rts
MEDUZA3:
		add.w	#1,NMD3
		cmp.w	#8,NMD3
		bne		MD03
		move.w	#0,NMD3
MD03:	sub.w	#3,YMD3
		cmp.w	#-108,YMD3
		bne		MD13
		move.w	#300,YMD3
MD13:	move.l	#MED,a1
		move.w	NMD3,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8048+3200,a0
		move.w	YMD3,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD23:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD23
		rts
MEDUZA4:
		add.w	#1,NMD4
		cmp.w	#8,NMD4
		bne		MD04
		move.w	#0,NMD4
MD04:	sub.w	#2,YMD4
		cmp.w	#-108,YMD4
		bne		MD14
		move.w	#300,YMD4
MD14:	move.l	#MED,a1
		move.w	NMD4,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8064+3200,a0
		move.w	YMD4,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD24:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD24
		rts
MEDUZA5:
		add.w	#1,NMD5
		cmp.w	#8,NMD5
		bne		MD05
		move.w	#0,NMD5
MD05:	sub.w	#1,YMD5
		cmp.w	#-108,YMD5
		bne		MD15
		move.w	#300,YMD5
MD15:	move.l	#MED,a1
		move.w	NMD5,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8080+3200,a0
		move.w	YMD5,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD25:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD25
		rts
MEDUZA6:
		add.w	#1,NMD6
		cmp.w	#8,NMD6
		bne		MD06
		move.w	#0,NMD6
MD06:	sub.w	#3,YMD6
		cmp.w	#-108,YMD6
		bne		MD16
		move.w	#300,YMD6
MD16:	move.l	#MED,a1
		move.w	NMD6,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8096+3200,a0
		move.w	YMD6,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD26:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD26
		rts
MEDUZA7:
		add.w	#1,NMD7
		cmp.w	#8,NMD7
		bne		MD07
		move.w	#0,NMD7
MD07:	sub.w	#1,YMD7
		cmp.w	#-108,YMD7
		bne		MD17
		move.w	#300,YMD7
MD17:	move.l	#MED,a1
		move.w	NMD7,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8112+3200,a0
		move.w	YMD7,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD27:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD27
		rts
MEDUZA8:
		add.w	#1,NMD8
		cmp.w	#8,NMD8
		bne		MD08
		move.w	#0,NMD8
MD08:	sub.w	#2,YMD8
		cmp.w	#-108,YMD8
		bne		MD18
		move.w	#300,YMD8
MD18:	move.l	#MED,a1
		move.w	NMD8,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8128+3200,a0
		move.w	YMD8,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD28:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD28
		rts
MEDUZA9:
		add.w	#1,NMD9
		cmp.w	#8,NMD9
		bne		MD09
		move.w	#0,NMD9
MD09:	sub.w	#2,YMD9
		cmp.w	#-108,YMD9
		bne		MD19
	 	move.w	#300,YMD9
MD19:	move.l	#MED,a1
		move.w	NMD9,d1
		mulu.w	#34*16,d1
		add.w	d1,a1
		move.l	#$78000+8144+3200,a0
		move.w	YMD9,d1
		mulu.w	#160,d1
		add.w	d1,a0
		move.w	#33,d0
MD29:	jsr		RYSUJ_MEDUZE
		dbf		d0,MD29
		rts
RYSUJ_MEDUZE:
		rept	2
		addq	#2,a0
		addq	#2,a1
		move.b	(a1)+,(a0)+	
		move.b	(a1)+,(a0)+	
		move.b	(a1)+,(a0)+	
		move.b	(a1)+,(a0)+	
		move.b	(a1)+,(a0)+	
		move.b	(a1)+,(a0)+	
		endr
		add.w	#144,a0
		rts

*-------------------------------------------------------------------------*

MED:		incbin	"A:ASEMBLER.S\DANE.DAT\MEDUZA.DAT"
NMD:		dc.w	1
YMD:		dc.w	1
CMD:		dc.w	1
CMD1:		dc.w	1
CMD2:		dc.w	1
CMD3:		dc.w	1
NMD1:		dc.w	1
YMD1:		dc.w	1
NMD2:		dc.w	1
YMD2:		dc.w	1
NMD3:		dc.w	1
YMD3:		dc.w	1
NMD4:		dc.w	1
YMD4:		dc.w	1
NMD5:		dc.w	1
YMD5:		dc.w	1
NMD6:		dc.w	1
YMD6:		dc.w	1
NMD7:		dc.w	1
YMD7:		dc.w	1
NMD8:		dc.w	1
YMD8:		dc.w	1
NMD9:		dc.w	1
YMD9:		dc.w	1
			even
