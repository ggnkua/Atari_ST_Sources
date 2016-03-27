	opt	x+
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	lea	6(a7),a7
	move.b	#0,$484.w
	bsr	SetColors
	lea	$78000,a0
	move.w	#1999,d7
	moveq	#0,d0
Loop	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,Loop
	move.b	#$12,$fffffc02.w
	move.b	#2,$ffff820a.w
	move.l	#$70080,$ffff8200.w
	move.w	#$2300,sr
RESET	lea	Parametry(pc),a1
	bra	Phraqtals
Next:	cmp.b	#$39,$fffffc02.w
	bne	Next


*************************************
*	     Generator		    *
*************************************
Phraqtals:
	lea	$78000,a0
	move.w	#1999,d7
	moveq	#0,d0
.ClrScr	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.ClrScr

	move.l	#$78000,AdrEkr+2
	move.w	#$8000,Exit+2
Restart	movem.w	(a1)+,d0-d3
	tst.w	d0
	bne	Okey
	lea	Parametry(pc),a1
	bra	Restart
Okey	move.w	d0,MAXX+2
	move.w	d1,MAXY+2
	move.w	d2,MINX+2
	move.w	d3,MINY+2
	move.w	#319,d0	;szerokosc
MamNowe	move.w	#199,d1	;wysokosc
AdrEkr	lea	00000,a0
MAXX	move.w	#0000,d2
	muls	d0,d2

	divs	#320,d2	;szer. (320)
	;ror.l	#8,d2	;szer. (256)

MINX	sub.w	#0000,d2
MAXY	move.w	#0000,d3
	muls	d1,d3

	divs	#200,d3	;wys. (200)
	;ror.l	#8,d3	;wys. (256)

MINY	sub.w	#0000,d3
	moveq	#0,d4
	moveq	#0,d5
	movem.w	d0-d1,-(a7)
	moveq	#15,d7
TAT	move.w	d4,d0
	move.w	d5,d1
	move.w	d1,d6
	muls	d6,d6
	lsr.l	#8,d6
	lsr.l	#2,d6
	move.w	d0,d4
	muls	d4,d4
	lsr.l	#8,d4
	lsr.l	#2,d4
	sub.w	d6,d4
	add.w	d2,d4
	move.w	d0,d5
	muls	d1,d5
	lsr.l	#8,d5
	lsr.l	#1,d5
	and.b	#$fe,d5
	add.w	d3,d5
	move.w	d4,d0
	muls	d0,d0
	lsr.l	#8,d0
	lsr.l	#2,d0
	move.w	d5,d1
	muls	d1,d1
	lsr.l	#8,d1
	lsr.l	#2,d1
	add.w	d0,d1
	cmp.w	#4096,d1
	bcc.s	Exit
	dbf	d7,TAT
Exit	move.w	#$8000,d6

	btst	#0,d7
	bne.s	B0
	or.w	d6,(a0)
B0	btst	#1,d7
	bne.s	B1
	or.w	d6,2(a0)
B1	btst	#2,d7
	bne.s	B2
	or.w	d6,4(a0)
B2	btst	#3,d7
	bne.s	B3
	or.w	d6,6(a0)
B3
	lea	160(a0),a0
	movem.w	(a7)+,d0-d1
	dbf	d1,MAXX
	lsr.w	#1,d6
	bne.s	Next16
	move.w	#$8000,d6
	addq.l	#8,AdrEkr+2
Next16	cmp.b	#129,$fffffc02.w
	beq	Koniec
	cmp.b	#$39,$fffffc02.w
	beq	Next
	move.w	d6,Exit+2
	dbf	d0,MamNowe
WaitKey	BCHG	#7,$78000
	BCHG	#7,$78002
	BCHG	#7,$78004
	BCHG	#7,$78006
	stop	#$2300
	cmp.b	#$39,$fffffc02.w ;space
	beq	Next
	cmp.b	#1,$fffffc02.w	;esc
	beq	Koniec
	bra.s	WaitKey
col0	rts
	move.l	d6,$70.w
	move.l	$466,$70
col1	or.w	d6,(a0)
	rts
	nop
	move.l	$466,$70
col2	or.w	d6,2(a0)
	rts
	move.l	$466,$70
col3	or.w	d6,(a0)
	or.w	d6,2(a0)
	rts
	move.l	$466,$70.w
col4	or.w	d6,4(a0)
	rts
	move.l	$466,$70
col5	or.w	d6,(a0)
	or.w	d6,4(a0)
	rts
	move.l	$466,$70.w
col6	or.w	d6,2(a0)
	or.w	d6,4(a0)
	rts
	move.l	$466.w,$70.w
col7	or.w	d6,(a0)
	or.w	d6,2(a0)
	or.w	d6,4(a0)
	rts
	move.l	d6,$70.w
col8	or.w	d6,6(a0)
	rts
	move.l	$466,$70
col9	or.w	d6,(a0)
	or.w	d6,6(a0)
	rts
	move.l	$466,$70.w
colA	or.w	d6,2(a0)
	or.w	d6,6(a0)
	rts
	move.l	$466.w,$70.w
colB	or.w	d6,(a0)
	or.w	d6,2(a0)
	or.w	d6,6(a0)
	rts
	move.l	d6,$70.w
colC	or.w	d6,4(a0)
	or.w	d6,6(a0)
	rts
	move.l	$466.w,$70.w
colD	or.w	d6,(a0)
	or.w	d6,4(a0)
	or.w	d6,6(a0)
	rts
	move.l	d6,$70.w
colE	or.w	d6,2(a0)
	or.w	d6,4(a0)
	or.w	d6,6(a0)
	rts
	nop
colF	or.w	d6,(a0)
	or.w	d6,2(a0)
	or.w	d6,4(a0)
	or.w	d6,6(a0)
	rts
SetColors
	clr.b	$ffff8260.w
	lea	$ffff8240.w,a0
	move.l	#$00000001,(a0)+
	move.l	#$00020003,(a0)+
	move.l	#$00040005,(a0)+
	move.l	#$00060007,(a0)+
	move.l	#$01070207,(a0)+
	move.l	#$03070407,(a0)+
	move.l	#$05070607,(a0)+
	move.l	#$07070717,(a0)
	rts
Koniec
	move.b	#7,$484.w
	move.b	#$8,$fffffc02.w
	clr.w	-(a7)
	trap	#1
	illegal
PlanesAdr
	dc.w	16,32,64
*************************************
********** Phraqtales Data **********
* a-high(+higer), b-long(+shorter)  *
*x-position(-left), y-position(-low)*
*************************************
Parametry:
	DC.W	3829,3908,2050,1950
	DC.W	170,475/2,63,941
	dc.w	1000,1000,0,0
	dc.w	2048,2048,1500,1024
	dc.w	1024,1024,0,500
	dc.w	1024,1024,500,0
	dc.w	10000,10000,5000,5000
	dc.w	1400,1400,700,700
	dc.w	400,1000,1600,500
	dc.w	30000,30000,15000,15000
	dc.w	60000,60000,30000,30000
	dc.w	40000,40000,20000,20000
	dc.w	-1000,-1000,-1000,-1000
	dc.w	4000,2000,2000,2000
	dc.w	2000,2000,2000,2000
	dc.w	1000,500,0,250
	dc.w	2024,1024,1500,0
	dc.w	1650,1000,1200,1200
	dc.w	1000,1000,1100,900 ;(600)
	ds.l	2
	end
