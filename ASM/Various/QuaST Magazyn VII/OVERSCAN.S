***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Overscan - powiekszajmy pole swojego ekranu               *
* autor      :  Costek                                                    *
* inne uwagi :  320x200 !!!                                               *
***************************************************************************

	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,-(sp)

	move.w #0,-(sp)
	move.l #$78000,-(sp)
	move.l #$78000,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp

	move.l #$78000,a0
	lea 160(a0),a0
	move.w #299,d0
maluj1
	move.w #240,d1
maluj
	move.b #$f0,(a0)+
	dbf d1,maluj
	dbf d0,maluj1

	move.w sr,status
	move.l $68,oldhbl
	move.l $70,oldvbl

	move.w #33,licznik
	move.b $fffa09,staryB
	bclr.b #7,$fffa07
	andi.b #%11011111,$fffa09
	move.l #hbl,$68
	move.l #vbl,$70
	andi.w #%1111100011111111,sr

loop
	cmp.b #185,$fffc02
	bne loop

	move.w status,sr        
	move.l oldhbl,$68
	move.l oldvbl,$70            
	move.b staryB,$fffa09
	move.b #200,$fffa23
	move.w $777,$ff8240
	move.b #2,$ff820a
	clr.l -(sp)
	trap #1

vbl
	move.l #hbl,$68
	move.w #32,licznik
	move.w #$2100,sr
	rte
hbl
	subq.w #1,licznik
	beq.s gorna
	rte
gorna
	move.l #gorna_out,$68
	stop	#$2100
gorna_out
	move.w #$2700,sr
	addq.l #6,sp
	rept 86
	nop
	endr
	move.b #0,$ff820a
	rept 17
	nop
	endr
	move.b #2,$ff820a
	lea $ff820a,a0
	lea $ff8260,a1
	moveq #0,d0
wait
	move.b $ff8209,d0
	beq.s wait
	not.w d0
	lsr.w d0,d0
	rept 71      
	nop
	endr
	move.w #226,d7
boki_out
	nop
	move.w a1,(a1)
	nop
	move.b d0,(a1)
	rept 89
	nop
	endr
	move.b d0,(a0)
	move.w a0,(a0)
	rept 13
	nop
	endr
	move.w a1,(a1)
	nop
	move.b d0,(a1)
	rept 8
	nop
	endr
	dbra d7,boki_out
	rept 109
	nop
	endr
	move.b #0,$ff820a
	rept 10
	nop
	endr
	move.b #2,$ff820a
	move.l #puste,$68
	rte
puste
*	move.b #2,$ff820a
	rte
licznik
	ds.w 1
oldhbl
	ds.l 1
oldvbl
	ds.l 1
status
	ds.w 1
staryB
	ds.b 1
