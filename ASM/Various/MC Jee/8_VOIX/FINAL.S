******************************************************************************
*                                                                            *
*     		Routine 8 voix du DIGITAL 030 cod‚ par MC JEE                *
*                                                                            *
******************************************************************************


debut	
	
	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	move.l d0,old_sp
	addq.w #6,sp
	lea mystack,a7

	move.l #digit1,player+12
	move.l #digit2,player+16
	move.l #volume_table,player+20
	move.l #note_table,player+24
	move.l #module,player+28
	bsr do_volume
	bsr do_note
	move.l player,a0
	add.l #player,a0
	jsr (a0)
	bsr init_adc
	
	move.w #$2700,SR
	lea $fffffa07.w,a0
	lea old_it,a6
	move.b (a0),(a6)+
	move.b 2(a0),(a6)+
	move.b 12(a0),(a6)+
	move.b 14(a0),(a6)+
	clr.b (a0)
	clr.b 2(a0)
	
	move.w #-1,-(a7)
	move.w #$58,-(a7)
	trap #14
	addq.w #4,a7
	move.w d0,(a6)+
	and.w #%110000,d0
	move.w d0,d7
	bset #1,d0
	move.w d0,-(a7)	;Marche a tous les coups car 32000/screen
	move.w #$58,-(a7)
	trap #14
	addq.w #4,a7
	btst #4,d7
	bne.s .vga
	sub.w #40,$ffff82a8.w	;240 lignes pour le RGB
	add.w #40,$ffff82aa.w
.vga	move.l #ecran+4,d0	
	and.b #$FC,d0
	move.l d0,p_ecran
	move.l d0,p_ecran+4
	move.l $ffff8200.w,(a6)+
	ror.w #8,d0
	move.l d0,$ffff8200.w
	move.b $ffff820d.w,(a6)+
	lsr.w #8,d0
	move.b d0,$ffff820d.w	
	addq.w #1,a6
	move.l $70.w,(a6)+
	move.l #myvbl,$70.w
	lea $ffff9800.w,a0
	move.w #$FF,d0
.loop	move.l (a0),(a6)+
	move.l #-1,(a0)+
	dbra d0,.loop
	clr.l $ffff9800.w
	
	move.w #$2300,SR

	bsr joue
	
.wait	cmp.b #$39,$fffffc02.w
	bne.s .wait
.wait_l	cmp.b #$39+$80,$fffffc02.w
	bne.s .wait_l
	
	move.w #$2700,sr
	bsr jouepas
	
	lea $fffffa07.w,a0
	lea old_it,a6
	move.b (a6)+,(a0)
	move.b (a6)+,2(a0)
	move.b (a6)+,12(a0)
	move.b (a6)+,14(a0)
	move.l 8(a6),$70.w
	move.l 2(a6),$ffff8200.w
	move.b 6(a6),$ffff820d.w
	move.w (a6)+,-(a7)
	move.w #88,-(a7)
	trap #14
	addq.w #4,a7
	add.w #10,a6
	lea $ffff9800.w,a0
	move.w #$FF,d0
.loop_2	move.l (a6)+,(a0)+
	dbra d0,.loop_2
	
	move.w #$2300,SR
	
	move.l old_sp,-(a7)
	move.w #32,-(a7)
	trap #1
	addq.w #6,a7
	
	clr.w -(sp)
	trap #1

myvbl	movem.l d0-d7/a0-a6,-(sp)
	addq.b #1,$465.w
	btst #0,$465.w
	bne .player
.player	move.w #$2700,SR
	tst.b player+32
	beq.s .no_calc
	sf player+32
	move.l player+8,a0
	add.l #player,a0
	jmp (a0)
.no_calc	movem.l (sp)+,d0-d7/a0-a6
	rte

joue	lea $ffff8900.w,a0
	moveq #0,d2	
	MOVE.L player+12,D0
	move.l d0,d1
	add.l #1001*4,d0
	
	clr.b 1(a0)		;OFF
	movep.l d1,1(a0)	;adr deb
	movep.l d0,$D(a0)	;adr fin
	and.b #$F0,$34(a0)
	or.b #1,$34(a0)
	and.b #$F0,$35(a0)
	or.b #1,$35(a0)
	move.w #$503,(a0)		;PLay & Repeat
	
	move.l player+4,a0
	add.l #player,a0
	move.l $13C.w,old_timera
	move.l a0,$13C.w
	
	bset #7,$fffffa07.w	;Let's go
	bset #7,$fffffa13.w
	RTS

jouepas	lea $ffff8900.w,a0
	clr.b 1(a0)
	bclr #7,$fffffa07.w
	bclr #7,$fffffa13.w
	move.l old_timera,$13c.w
	RTS

**********************************
* Produit la table des volumes   *
**********************************
do_volume:
	lea volume_table,a0
	add.l #$8200,a0
	move.w #$40,d0
	moveq #15,d7
init1:	move.w #$ff,d1
init2:	move.w d1,d2
	ext.w d2
	muls d0,d2
	asl.l d7,d2
	divs.l #$8000,d2
	move.w d2,-(a0)
	dbf d1,init2
	dbf d0,init1
	rts

do_note:	lea note_table+($390*4),a0
	
	move.l #$123,d3
	move.l #$359E0000,d4
	move.w #$38f,d2

.loop	moveq #0,d7
	MOVE.W	D2,D7
	BEQ.S	.stop
	MOVE.L	D3,D0		;11E
	MOVE.L	D4,D1		;5d1d
	DIVU	D7,D0
	SWAP	D0
	MOVE.W	D0,D1
	SWAP	D1
	DIVU	D7,D1
	MOVE.W	D1,D0
	lsr.l #2,d0
	move.l d0,-(a0)
	dbra d2,.loop
.stop	clr.l -(a0)
	rts

;*** Variable de ADC
init_adc	
	move.w #1,-(sp)	;16 Bits
	move.w #$84,-(sp)
	trap #14
	addq.w #4,sp
	
	clr.W	-(A7)	;Track play record 0,0
	clr.W	-(A7)
	MOVE.W	#$85,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	
	clr.W	-(A7)	;Input from
	MOVE.W	#5,-(A7)
	MOVE.W	#$82,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	
	clr.W	-(A7)	;Montrack 0
	MOVE.W	#$86,-(A7)
	TRAP	#14
	ADDQ.L	#4,A7
	
	move.w #2,-(sp)	;Matrix
	move.w #4,-(sp)
	move.w #$82,-(sp)
	trap #14
	addq.w #6,sp
	
	move.w 	#1,-(sp)
	move.w 	#0,-(sp)
	move.w 	#0,-(sp)
	move.w 	#8,-(sp)
	move.w 	#0,-(sp)
	move.w 	#$8b,-(sp)
	trap 	#14
	lea 	12(sp),sp
	
	
	MOVEq	#0,D0
	MOVEq	#1,D1
	BSR	SDMA_INT
	
	move.w #1,-(sp)	;16 Bits
	move.w #$84,-(sp)
	trap #14
	addq.w #4,sp
	RTS
	
SDMA_INT	MOVE.W	D1,-(A7)
	MOVE.W	D0,-(A7)
	MOVE.W	#$87,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	RTS


	
	section data

player	incbin '8demov2.bin'
module	incbin 'cd2part0.mod'
	section bss
	ds.w 2500*31
old_sp	ds.l 1
old_it	ds.l 268
old_timera	ds.l 1
p_ecran	ds.l 2
ecran	ds.w 4+160*240	;2 ecran et pour vga aussi...
	ds.l 100
mystack
digit1		ds.l 6000
digit2		ds.l 6000
volume_table	ds.w 256*65
note_table		ds.l $390