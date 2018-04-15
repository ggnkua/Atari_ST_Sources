	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.L	#0,$4D2
	MOVE.L	#0,$4D6
	move.w	#0,$FF8900
	MOVE.W	#$486,$FFFF8922
	move.b #12,$fffc02
	move.w #0,-(a7)
	move.l #$78000,-(a7)
	move.l #$78000,-(a7)
	move.w #5,-(a7)
	trap #14
	add.l #12,a7
	jmp	prg
MUZEXX incbin del31.mus
	even
prg	lea palimg,a0
	lea $ff8240,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
	pea txt
	move.w #9,-(a7)
	trap #1
	add.l #6,a7
tst	cmp.b #1,$fffc02
	bne tst
	pea txt2
	move.w #9,-(a7)
	trap #1
	add.l #6,a7	
	move.l #0,d2
	move.l #76,d3
	bsr calc
	JSR	INIT_MUZEXX
	JSR	PLAY_MUZEXX

	bsr inter

	move.l #prog,$70
	move.l	#VBL,$4D2
key:
	move.b $fffc02,d1
	cmp.b #$39,d1
	bne key
	move.l s70,$70
	move.l s120,$120
	move.b sa21,$fffa21
	move.b sa1b,$fffa1b
	move.b sa07,$fffa07
	move.b sa13,$fffa13
	move.b sa09,$fffa09
	move.w	#0,$FF8900
	move.l	#0,$4D2
	JMP	$8C

inter
	move.l $120,s120
	move.l $70,s70
	move.l $70,j+2
	move.b $fffa21,sa21
	move.b $fffa1b,sa1b
	move.b $fffa07,sa07 
 	move.b $fffa13,sa13
	move.b $fffa09,sa09
 	and.b #$ef,$fffa13
 	and.b #$ef,$fffa0f
 	and.b #$ef,$fffa0b
 	clr.b $fffa07
 	clr.b $fffa1b
	clr.b $fffa09
 	or.b #1,$fffa07
 	or.b #1,$fffa13
	rts
s120	dc.l 0
s70	dc.l 0
sa21	dc.l 0
sa1b	dc.l 0
sa07	dc.l 0
sa13	dc.l 0
sa09	dc.l 0

prog	
	move.b #1,$fffa21
	move.b #8,$fffa1b
	move.w	#$3,$ff8240+24
	move.w	#$3,$ff8240+28
	move.l #0,pospal
	movem.l a0-a6/d0-d2,-(a7)
	move.l #it1a,$120.w
	lea tab1,a4
	add.l pos1,a4
	cmp.b #-1,(a4)
	bne ct1
	lea tab1,a4
	move.l #0,pos1
ct1	move.b (a4)+,it1a+3
	move.b (a4)+,it1b+3
	move.b (a4)+,it1c+3
	move.b (a4)+,it1d+3
	move.b (a4)+,it1e+3
	add.l #5,pos1
	lea tab2,a4
	add.l pos2,a4
	cmp.b #-1,(a4)
	bne ct2
	lea tab2,a4
	move.l #0,pos2
ct2	move.b (a4)+,it2a+3
	move.b (a4)+,it2b+3
	move.b (a4)+,it2c+3
	move.b (a4)+,it2d+3
	move.b (a4)+,it2e+3
	add.l #5,pos2
	lea tab3,a4
	add.l pos3,a4 
	cmp.b #-1,(a4)
	bne ct3
	lea tab3,a4
	move.l #0,pos3
ct3	move.b (a4)+,it3a+3
	move.b (a4)+,it3b+3
	move.b (a4)+,it3c+3
	move.b (a4)+,it3d+3
	move.b (a4)+,it3e+3
	add.l #5,pos3
	lea tab4,a4
	add.l pos4,a4
	cmp.b #-1,(a4)
	bne ct4
	lea tab4,a4
	move.l #0,pos4
ct4	move.b (a4)+,it4a+3
	move.b (a4)+,it4b+3
	move.b #80,it4b+3
	move.b (a4)+,it4c+3
	move.b (a4)+,it4d+3
	move.b (a4)+,it4e+3
	add.l #5,pos4
	lea tab5,a4
	add.l pos5,a4
	cmp.b #-1,(a4)
	bne ct5
	lea tab5,a4
	move.l #0,pos5
ct5	move.b (a4)+,it5a+3
	move.b (a4)+,it5b+3
	move.b (a4)+,it5c+3
	move.b (a4)+,it5d+3
	move.b (a4)+,it5e+3
	add.l #5,pos5
	lea tab6,a4
	add.l pos6,a4
	cmp.b #-1,(a4)
	bne ct6
	lea tab6,a4
	move.l #0,pos6
ct6	move.b (a4)+,it6a+3
	move.b (a4)+,it6b+3
	move.b (a4)+,it6c+3
	move.b (a4)+,it6d+3
	move.b (a4)+,it6e+3
	add.l #5,pos6
	lea tab7,a4
	add.l pos7,a4
	cmp.b #-1,(a4)
	bne ct7
	lea tab7,a4
	move.l #0,pos7
ct7	move.b (a4)+,it7a+3
	move.b (a4)+,it7b+3
	move.b (a4)+,it7c+3
	move.b (a4)+,it7d+3
	move.b (a4)+,it7e+3
	add.l #5,pos7
	lea tab8,a4
	add.l pos8,a4
	cmp.b #-1,(a4)
	bne ct8
	lea tab8,a4
	move.l #0,pos8
ct8	move.b (a4)+,it8a+3
	move.b (a4)+,it8b+3
	move.b (a4)+,it8c+3
	move.b (a4)+,it8d+3
	move.b (a4)+,it8e+3
	add.l #5,pos8
	lea tab9,a4
	add.l pos9,a4
	cmp.b #-1,(a4)
	bne ct9
	lea tab9,a4
	move.l #0,pos9
ct9	move.b (a4)+,it9a+3
	move.b (a4)+,it9b+3
	move.b (a4)+,it9c+3
	move.b (a4)+,it9d+3
	move.b (a4)+,it9e+3
	add.l #5,pos9
	lea tab10,a4
	add.l pos10,a4
	cmp.b #-1,(a4)
	bne ct10
	lea tab10,a4
	move.l #0,pos10
ct10	move.b (a4)+,it10a+3
	move.b (a4)+,it10b+3
	move.b (a4)+,it10c+3
	move.b (a4)+,it10d+3
	move.b (a4)+,it10e+3
	add.l #5,pos10
	lea tab11,a4
	add.l pos11,a4
	cmp.b #-1,(a4)
	bne ct11
	lea tab11,a4
	move.l #0,pos11
ct11	move.b (a4)+,it11a+3
	move.b (a4)+,it11b+3
	move.b (a4)+,it11c+3
	move.b (a4)+,it11d+3
	move.b (a4)+,it11e+3
	add.l #5,pos11	
	lea tab12,a4
	add.l pos12,a4
	cmp.b #-1,(a4)
	bne ct12
	lea tab12,a4
	move.l #0,pos12
ct12	move.b (a4)+,it12a+3
	move.b (a4)+,it12b+3
	move.b (a4)+,it12c+3
	move.b (a4)+,it12d+3
	move.b (a4)+,it12e+3
	add.l #5,pos12	
	lea tab13,a4
	add.l pos13,a4
	cmp.b #-1,(a4)
	bne ct13
	lea tab13,a4
	move.l #0,pos13
ct13	move.b (a4)+,it13a+3
	move.b (a4)+,it13b+3
	move.b (a4)+,it13c+3
	move.b (a4)+,it13d+3
	move.b (a4)+,it13e+3
	add.l #5,pos13	
	lea tab14,a4
	add.l pos14,a4
	cmp.b #-1,(a4)
	bne ct14
	lea tab14,a4
	move.l #0,pos14
ct14	move.b (a4)+,it14a+3
	move.b (a4)+,it14b+3
	move.b (a4)+,it14c+3
	move.b (a4)+,it14d+3
	move.b (a4)+,it14e+3
	add.l #5,pos14	
	;move.w	#$770,$ff8240
	addq.b	#1,wait
	cmp.b	#3,wait
	bne	suite
	move.b	#0,wait
	lea hand,a0
	add.l posh,a0
	cmp.b #-1,(a0)
	bne handsuit
	lea hand,a0
	move.l #0,posh
handsuit
	add.l #4,posh
	move.l (a0),a0
	lea	ecran2,a1
	add.l	#55*320+160-8,a1
o	set 0
n	set 0
	rept 22
	movem.l n(a0),a2-a6/d0
	movem.l a2-a6/d0,o(a1)
o	set o+320
n	set n+160
	endr
	;move.w	#7,$ff8240

	lea monster,a0
	add.l posm,a0
	cmp.b #-1,(a0)
	bne monstersuit
	lea monster,a0
	move.l #0,posm
monstersuit
	add.l #4,posm
	cmp.l	#M+32,(a0)
	beq	m2
	cmp.l	#M+64,(a0)
	beq	m2
	cmp.l	#M,(a0)
	beq	m2
	move.l (a0),a0
	lea	ecran2,a1
	add.l	#52*320+160+80,a1
o	set 0
n	set 0
	rept 60
	movem.l n(a0),a2-a6/d0-d2
	movem.l a2-a6/d0-d2,o(a1)
o	set o+320
n	set n+160
	endr
	;move.w	#$707,$ff8240
	bra	m3

m2	move.l (a0),a0
	lea	ecran2,a1
	add.l	#47*320+160+80,a1
o	set 0
n	set 0
	rept 56
	movem.l n(a0),a2-a6/d0-d2
	movem.l a2-a6/d0-d2,o(a1)
o	set o+320
n	set n+160
	endr
	;move.w	#$707,$ff8240

m3	lea scooter,a0
	add.l poss,a0
	cmp.b #-1,(a0)
	bne scootersuit
	lea scooter,a0
	move.l #0,poss
scootersuit
	add.l #4,poss
	move.l (a0),a0
	lea	ecran2,a1
	add.l	#128*320+160+96+8,a1
o	set 0
n	set 0
	rept 13
	movem.l n(a0),a2-a5
	movem.l a2-a5,o(a1)
o	set o+320
n	set n+160
	endr
suite	move.l	#100,d0
wai	dbf d0,wai
	movem.l (a7)+,a0-a6/d0-d2
	move.w	#0,$ff8240
j	jmp $12345678

it1a	move.b #0,$ff8265
it1b	move.b #0,$ff820f
it1c	move.b #0,$ff8209
it1d	move.b #0,$ff8207
it1e	move.b #0,$ff8205
	move.b #16,$fffa21
	move.l #it1,$120.w
 	bclr #0,$fffa0f
	rte
	
it1	move.l #it2a,$120.w
	move.b #10,$fffa21
 	bclr #0,$fffa0f
	rte
it2a	move.b #0,$ff8265
it2b	move.b #0,$ff820f
it2c	move.b #0,$ff8209
it2d	move.b #0,$ff8207
it2e	move.b #0,$ff8205
	move.w	#$b,$ff8240+28
	move.b #7,$fffa21
	move.l #it3a,$120.w
 	bclr #0,$fffa0f
	rte
it3a	move.b #0,$ff8265
it3b	move.b #0,$ff820f
it3c	move.b #0,$ff8209
it3d	move.b #0,$ff8207
it3e	move.b #0,$ff8205
	move.w	#$4,$ff8240+28
	move.b #4,$fffa21
	move.l #i1,$120.w
 	bclr #0,$fffa0f
	rte
i1	move.w	#$c,$ff8240+28
	move.w	#$700,$ff8240+24
	move.b #3,$fffa21
	move.l #i2,$120.w
 	bclr #0,$fffa0f
	rte
i2	move.w	#$5,$ff8240+28
	move.b #1,$fffa21
	move.l #i3,$120.w
 	bclr #0,$fffa0f
	rte
i3	move.w	#$d,$ff8240+28
	move.b #2,$fffa21
	move.l #it4a,$120.w
 	bclr #0,$fffa0f
	rte
it4a	move.b #0,$ff8265
it4b	move.b #0,$ff820f
it4c	move.b #0,$ff8209
it4d	move.b #0,$ff8207
it4e	move.b #0,$ff8205
	move.b #3,$fffa21
	move.l #i4,$120.w
 	bclr #0,$fffa0f
	rte
i4	move.w	#$6,$ff8240+28
	move.l #i5,$120.w
 	bclr #0,$fffa0f
	rte
i5	move.w	#$e,$ff8240+28
	move.l #i6,$120.w
 	bclr #0,$fffa0f
	rte
i6	move.w	#$7,$ff8240+28
	move.l #i7,$120.w
 	bclr #0,$fffa0f
	rte
i7	move.w	#$f,$ff8240+28
	move.b #88,$fffa21
	move.l #i8,$120.w
 	bclr #0,$fffa0f
	rte
i8	move.w	#$f,$ff8240+28
	move.b #4,$fffa21
	move.l #it5a,$120.w
 	bclr #0,$fffa0f
	rte

i9	move.w	#$9f,$ff8240+28
	move.l #i10,$120.w
 	bclr #0,$fffa0f
	rte
i10	move.w	#$2f,$ff8240+28
	move.l #i11,$120.w
 	bclr #0,$fffa0f
	rte
i11	move.w	#$af,$ff8240+28
	move.l #i12,$120.w
 	bclr #0,$fffa0f
	rte
i12	move.w	#$3f,$ff8240+28
	move.l #i13,$120.w
 	bclr #0,$fffa0f
	rte
i13	move.w	#$bf,$ff8240+28
	move.l #it5a,$120.w
 	bclr #0,$fffa0f
	rte
it5a	move.b #0,$ff8265
it5b	move.b #0,$ff820f
it5c	move.b #0,$ff8209
it5d	move.b #0,$ff8207
it5e	move.b #0,$ff8205
	move.b #4,$fffa21
	move.l #it6a,$120.w
 	bclr #0,$fffa0f
	rte
it6a	move.b #0,$ff8265
it6b	move.b #0,$ff820f
it6c	move.b #0,$ff8209
it6d	move.b #0,$ff8207
it6e	move.b #0,$ff8205
	move.b #5,$fffa21
	move.l #it7a,$120.w
 	bclr #0,$fffa0f
	rte
it7a	move.b #0,$ff8265
it7b	move.b #0,$ff820f
it7c	move.b #0,$ff8209
it7d	move.b #0,$ff8207
it7e	move.b #0,$ff8205
	move.b #5,$fffa21
	move.l #it8a,$120.w
 	bclr #0,$fffa0f
	rte
it8a	move.b #0,$ff8265
it8b	move.b #0,$ff820f
it8c	move.b #0,$ff8209
it8d	move.b #0,$ff8207
it8e	move.b #0,$ff8205
	move.b #5,$fffa21
	move.l #it9a,$120.w
 	bclr #0,$fffa0f
	rte
it9a	move.b #0,$ff8265
it9b	move.b #0,$ff820f
it9c	move.b #0,$ff8209
it9d	move.b #0,$ff8207
it9e	move.b #0,$ff8205
	move.b #6,$fffa21
	move.l #it10a,$120.w
 	bclr #0,$fffa0f
	rte
it10a	move.b #0,$ff8265
it10b	move.b #0,$ff820f
it10c	move.b #0,$ff8209
it10d	move.b #0,$ff8207
it10e	move.b #0,$ff8205
	move.b #6,$fffa21
	move.l #it11a,$120.w
 	bclr #0,$fffa0f
	rte
it11a	move.b #0,$ff8265
it11b	move.b #0,$ff820f
it11c	move.b #0,$ff8209
it11d	move.b #0,$ff8207
it11e	move.b #0,$ff8205
	move.b #6,$fffa21
	move.l #it12a,$120.w
 	bclr #0,$fffa0f
	rte
it12a	move.b #0,$ff8265
it12b	move.b #0,$ff820f
it12c	move.b #0,$ff8209
it12d	move.b #0,$ff8207
it12e	move.b #0,$ff8205
	move.b #8,$fffa21
	move.l #it13a,$120.w
 	bclr #0,$fffa0f
	rte
it13a	move.b #0,$ff8265
it13b	move.b #0,$ff820f
it13c	move.b #0,$ff8209
it13d	move.b #0,$ff8207
it13e	move.b #0,$ff8205
	move.b #8,$fffa21		;
	move.l #it14a,$120.w
 	bclr #0,$fffa0f
	rte
it14a	move.b #0,$ff8265
it14b	move.b #0,$ff820f
it14c	move.b #0,$ff8209
it14d	move.b #0,$ff8207
it14e	move.b #0,$ff8205
	clr.b $fffa21
	clr.b $fffa1b
 	bclr #0,$fffa0f
	rte
calc
	lea ecran2,a0				;ou?
	move.l a0,a2
	lea tab1,a1				;tableau1
	moveq #0,d1				
	moveq #0,d2				
	move.w #79,d4 			;repetition
	move.b #4,d5				;incrementation de 4
	bsr calcul				;allons-y

	lea ecran2+18*320,a0
	move.l a0,a2
	lea tab2,a1
	moveq #0,d1
	moveq #0,d2
	move.w #159,d4
	move.b #2,d5
	bsr calcul

	lea ecran2+30*320,a0
	move.l a0,a2
	lea tab3,a1
	moveq #0,d1
	moveq #0,d2
	move.w #319,d4
	move.b #1,d5
	bsr calcul

	lea ecran2-32+38*320,a0
	move.l a0,a2
	lea tab4,a1
	moveq #0,d1
	moveq #0,d2
	move.w #4,d4
	moveq #0,d5
	bsr calcul
	
	lea ecran2+141*320,a0
	move.l a0,a2
	lea tab5,a1
	moveq #0,d1
	moveq #0,d2
	move.w #319,d4
	move.w #1,d5
	bsr calcul

	lea ecran2+145*320,a0
	move.l a0,a2
	lea tab6,a1
	moveq #0,d1
	moveq #0,d1
	move.w #159,d4
	move.w #2,d5
	bsr calcul

	lea ecran2+149*320,a0
	move.l a0,a2
	lea tab7,a1
	moveq #0,d1
	moveq #0,d2
	move.w #319,d4
	move.w #3,d5
	bsr calcul
	
	lea ecran2+154*320,a0
	move.l a0,a2
	lea tab8,a1
	moveq #0,d1
	moveq #0,d2
	move.w #79,d4
	move.w #4,d5
	bsr calcul

	lea ecran2+159*320,a0
	move.l a0,a2
	lea tab9,a1
	moveq #0,d1
	moveq #0,d2
	move.w #319,d4
	move.w #5,d5
	bsr calcul

	lea ecran2+165*320,a0
	move.l a0,a2
	lea tab10,a1
	moveq #0,d1
	moveq #0,d2
	move.w #319,d4
	move.w #6,d5
	bsr calcul
	
	lea ecran2+171*320,a0
	move.l a0,a2
	lea tab11,a1
	moveq #0,d1
	moveq #0,d2
	move.w #319,d4
	move.w #7,d5
	bsr calcul

	lea ecran2+177*320,a0
	move.l a0,a2
	lea tab12,a1
	moveq #0,d1
	moveq #0,d2
	move.w #319,d4
	move.w #8,d5
	bsr calcul

	lea ecran2+183*320,a0
	move.l a0,a2
	lea tab13,a1
	moveq #0,d1
	moveq #0,d2
	move.w #319,d4
	move.w #9,d5
	bsr calcul
	
	lea ecran2+191*320,a0		;
	move.l a0,a2
	lea tab14,a1
	moveq #0,d1
	moveq #0,d2
	move.w #319,d4
	move.w #10,d5
	bsr calcul

	rts
calcul	move.b #160,d2
calcu	move.b #76,d3
	sub.b d5,d1		;add.b
	cmp.b #0,d1		;#16
	bge cnt		;blt
	add.b #16,d1		;sub.b
cal	sub.b #8,d2		;sub
	cmp.b #0,d2		;#160
	bne cnt
	move.b #160,d2	;#0
cnt	cmp.b	#0,d1
	bne cnt2
	move.b #80,d3
cnt2	move.b d1,(a1)+
	move.b d3,(a1)+
	move.l a2,a0
	add.l	d2,a0
	move.l a0,d0
	move.b d0,(a1)+
	lsr.w #8,d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	dbf d4,calcu
	rts
	

INIT_MUZEXX
	LEA		SEQ(PC),A0
	LEA		PAT(PC),A1
	LEA		NBR_INS(PC),A2
	LEA		MUZEXX,A3
	MOVE	#$1D8,(A0)
	MOVE	#$258,(A1)
	MOVE	#15,(A2)
	CMP.L	#'M.K.',$438(A3)
	BNE		REAL_DOCs_MODULE
	MOVE	#$3B8,(A0)
	MOVE	#$43C,(A1)
	MOVE	#31,(A2)
REAL_DOCs_MODULE

	LEA		MUZEXX,A0
	ADD		SEQ(PC),A0
	MOVE.L	#$80,D0
	MOVEQ	#0,D1
INIT_MUZEXX1
	MOVE.L	D1,D2
	SUBQ	#1,D0
INIT_MUZEXX2
	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	INIT_MUZEXX1
	DBF		D0,INIT_MUZEXX2
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	LEA		MUZEXX,A0
	ADD		PAT,A0
	ADD.L	D2,A0
	LEA		20+MUZEXX,A1
	LEA		16+INS(PC),A2
	MOVE	NBR_INS(PC),D0
	SUBQ	#1,D0
INIT_MUZEXX3
	MOVE.L	A0,4(A2)
	MOVEQ	#0,D1
	MOVE	22(A1),D1
	LSL.L	#1,D1
	MOVE.L	D1,(A2)
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE	24(A1),D1
	BEQ		INIT_MUZEXX4
	SUBQ	#1,D1
INIT_MUZEXX4
	MOVE	D1,12(A2)
	MOVEQ	#0,D1
	MOVE	28(A1),D1
	LSL.L	#1,D1
	CMP.L	#2,D1
	BNE		INIT_MUZEXX5
	MOVEQ	#0,D1
INIT_MUZEXX5
	SWAP	D1
	MOVE.L	D1,8(A2)
	LEA		30(A1),A1
	LEA		16(A2),A2
	DBRA	D0,INIT_MUZEXX3


	LEA 		MU,A0
	MOVE.W		#2520,D0
CCLR	MOVE.L 	#0,(A0)+
	DBF		D0,CCLR
 	
	MOVE.W	#2,$FF8920   ;sound-mode
				;00 6250hz
				;1  12517hz
				;2  25033hz
				;3  50066hz
				; mono +128 

	LEA		MUSIQUE_END,A0	
	MOVE.L		A0,D0
	MOVE.W		D0,$FF8912
	ROR.L		#8,D0
	MOVE.W		D0,$FF8910
	ROR.L		#8,D0
	MOVE.W		D0,$FF890E

	LEA		MU,A0
	MOVE.L		A0,D0
	MOVE.W		D0,$FF8906
	ROR.L		#8,D0
	MOVE.W		D0,$FF8904
	ROR.L		#8,D0
	MOVE.W		D0,$FF8902
	MOVE.L		#$33fc0003,rt
	MOVE.L		#$00ff8900,rt+4
	
	RTS


PLAY_MUZEXX
ON	
	MOVE	#6,SPD+2
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA		MUZEXX,A0
	ADD		SEQ(PC),A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF(PC),A0
	LEA		OFF(PC),A1
	LEA		OFF(PC),A2
	LEA		OFF(PC),A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2
	MOVE.W	#20160/4,D0
	LEA	MU,A0
CLRR	MOVE.L #0,(A0)+
	DBF D0,CLRR
	RTS




MUSC		DC.L	MU,MU+1008,MU+2016,MU+3024,MU+4032,MU+5040,MU+6048
		DC.L	MU+7056,MU+8064,MU+9072,MU+10080,MU+11088,MU+12096
		DC.L	MU+13104,MU+14112,MU+15120,MU+16128,MU+17136,MU+18144
		DC.L	MU+19152

AMIGA	
	MOVE.B		MUSI,D7
	ADDQ.B		#4,D7
	CMP.B		#80,D7
	BNE.S		AM3
	MOVEQ.B	#0,D7
AM3
	MOVE.B		D7,MUSI
	MOVE.L		MUSC(PC,D7.W),A4
AMM
	MOVEQ		#0,D7
	MOVE.W		#504,D6
AM2
	SWAP		D0					;2 DOUBLE CYCLES	
	SWAP		D1					;2
	SWAP		D2					;2
	SWAP		D3					;2
V0	SUB.L		#0,D0					;8
	BMI.S		L0					;4
V1	SUB.L		#0,D1					;8
	BMI.S		L1					;4
V2	SUB.L		#0,D2					;8
	BMI.S		L2					;4
V3	SUB.L		#0,D3					;8
	BMI.S		L3					;4
OUT	SWAP		D0					;2
	SWAP		D1					;2
	SWAP		D2					;2
	SWAP		D3					;2
	MOVE.B		0(A0,D0),D4				;7
	MOVE.B		0(A1,D1),D5				;7
	ADD.B		0(A2,D2),D4				;7
	ADD.B		0(A3,D3),D5				;7	
	SUB.B		#$80,D4
	SUB.B		#$80,D5
	MOVE.B		D4,(A4)+			
	MOVE.B		D5,(A4)+
	DBF		D6,AM2
rt	MOVE.W 	#3,$FF8900
	MOVE.W		#$4E75,rt
	RTS
	
L0	MOVE.L		#0,D0
F0	MOVE.L		#0,V0+2
	BRA		V1
L1	MOVE.L		#0,D1
F1	MOVE.L		#0,V1+2
	BRA		V2
L2	MOVE.L		#0,D2
F2	MOVE.L		#0,V2+2
	BRA		V3
L3	MOVE.L		#0,D3
F3	MOVE.L		#0,V3+2
	BRA		OUT

VBL	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEM.L	REGIS,D0-D6/A0-A6
	;MOVE.W		#$700,$FF8240
	JSR		AMIGA
	MOVE.L	#400,D6
WAA	DBF	D6,WAA
	;MOVE.W		#7,$FF8240
	SUBQ.B	#1,SPEED
	BEQ.S	PLAY
	;MOVE.W		#5,$FF8240
	JSR		EFFECT
END_VBL
	;MOVE.W		#$777,$FF8240
	MOVEM.L	D0-D6/A0-A6,REGIS
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

PLAY
NO_KEYBOARD1
	MOVEM.L	D0-D1/A0-A5,-(SP)
SPD	MOVE.B	#6,SPEED
	SUBQ.B	#1,POS
	BNE		NO_NEW_PATTERN
	MOVE.B	#64,POS
	ADDQ.L	#1,MUS+2
	SUBQ.B	#1,TRK
	BMI		RESTART
	MOVEQ	#0,D0
MUS	MOVE.B	$0,D0
	SWAP	D0
	LSR.L	#6,D0
	LEA		MUZEXX,A0
	ADD		PAT(PC),A0
	ADD.L	D0,A0
	MOVE.L	A0,ADD_IN_PAT
NO_NEW_PATTERN
	MOVE.L	ADD_IN_PAT(PC),A0
	LEA		FRQ(PC),A1
	LEA		INS(PC),A2
	LEA		COMMAND,A3
	LEA		VOICE0(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE1(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE2(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE3(PC),A4
	BSR		LOAD_VOICE
	MOVE.L	A0,ADD_IN_PAT
	MOVEM.L	(SP)+,D0-D1/A0-A5
* ADDRESS ALL 4 VOICES
	MOVEM.L	D4/A5,-(SP)
	LEA		VOICE0(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT0
	MOVE.L	(A5),D0
	MOVE.L	4(A5),A0
	MOVE.L	8(A5),D4
	MOVE.L	D4,L0+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V0+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F0+2
CONT0
	CLR.B	20(A5)
	LEA		VOICE1(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT1
	MOVE.L	(A5),D1
	MOVE.L	4(A5),A1
	MOVE.L	8(A5),D4
	MOVE.L	D4,L1+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V1+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F1+2
CONT1
	CLR.B	20(A5)
	LEA		VOICE2(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT2
	MOVE.L	(A5),D2
	MOVE.L	4(A5),A2
	MOVE.L	8(A5),D4
	MOVE.L	D4,L2+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V2+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F2+2
CONT2
	CLR.B	20(A5)
	LEA		VOICE3(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT3
	MOVE.L	(A5),D3
	MOVE.L	4(A5),A3
	MOVE.L	8(A5),D4
	MOVE.L	D4,L3+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V3+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F3+2
CONT3
	CLR.B	20(A5)
	MOVEM.L	(SP)+,D4/A5

	BRA		END_VBL

LOAD_VOICE
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE	D0,30(A4)
	MOVE	(A0)+,D0
	BEQ.S	COMMAND?
	BTST	#12,D0
	BEQ.S	CONT_FRQ
	AND		#$FFF,D0
	MOVE	#$100,D1
CONT_FRQ
	MOVE.B	#1,20(A4)
	MOVE	D0,24(A4)
	ADD		D0,D0
	ADD		D0,D0
	MOVE.L	(A1,D0.W),D0
	MOVE.L	D0,12(A4)
	TST.L	16(A4)
	BEQ.S	CONT_LOAD_FRQ
	MOVE.L	D0,16(A4)
CONT_LOAD_FRQ
	OR.B	(A0),D1
	AND		#$FF0,D1
	BEQ.S	COMMAND?
	MOVE.L	12(A4),16(A4)
	MOVE.L	0(A2,D1.W),(A4)
	MOVE.L	4(A2,D1.W),4(A4)
	MOVE.L	8(A2,D1.W),8(A4)
	BNE.S	REPEAT
	CLR.L	16(A4)
REPEAT
COMMAND?
	MOVE	(A0)+,D0
	MOVE.B	D0,D1
	AND		#$F00,D0
	LSR		#6,D0
	MOVE.L	(A3,D0.W),A5
	JMP		(A5)

NO_COMMAND
	RTS

ARPEGGIO
	TST.B	D1
	BEQ.S	NO_ARPEGGIO
	MOVE.B	#0,22(A4)
	MOVE.B	D1,23(A4)
	MOVE.B	#1,21(A4)		*ARPEGGIO COUNTER
	MOVE	#1,30(A4)
NO_ARPEGGIO
	RTS

PORTAMENTO_UP
	MOVE.B	#1,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

PORTAMENTO_DOWN
	MOVE.B	#2,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

POSITION_JUMP
	LEA		MUZEXX,A5
	ADD		SEQ(PC),A5
	LEA		-1(A5),A5
	MOVE.B	#1,POS
	MOVE.L	A5,D0
	ADD.L	D1,D0
	MOVE.L	D0,MUS+2
	MOVE.B	-1(A5),D0
	SUB		D1,D0
	MOVE.B	D0,TRK
	RTS

SET_VOLUME
	TST.B	D1
	BNE.S	NO_CHANGE			*NO REAL TIME VOLUME VARIATION
	CLR.L	12(A4)				*IN THIS VERSION! MAYBE
	MOVE.B	#1,20(A4)			*SOME OTHER DAY...
NO_CHANGE
	RTS

PATTERN_BREAK
	MOVE.B	#1,POS
	RTS

SET_FILTER
	RTS

SET_SPEED
	MOVE.B	D1,SPD+3
	MOVE.B	D1,SPEED
	RTS

COMMAND		DC.L	ARPEGGIO,PORTAMENTO_UP,PORTAMENTO_DOWN,NO_COMMAND
			DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,NO_COMMAND
			DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,POSITION_JUMP
			DC.L	SET_VOLUME,PATTERN_BREAK,SET_FILTER,SET_SPEED

EFFECT
	MOVEM.L	D4-D6/A4-A6,-(SP)
	LEA		FRQ(PC),A5
	LEA		VOICE0(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT1
	BSR		DO_EFFECT
	MOVE.L	26(A6),V0+2
	TST.L	F0+2
	BEQ.S	CONT_EFFECT1
	MOVE.L	26(A6),F0+2
CONT_EFFECT1
	LEA		VOICE1(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT2
	BSR		DO_EFFECT
	MOVE.L	26(A6),V1+2
	TST.L	F1+2
	BEQ.S	CONT_EFFECT2
	MOVE.L	26(A6),F1+2
CONT_EFFECT2
	LEA		VOICE2(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT3
	BSR		DO_EFFECT
	MOVE.L	26(A6),V2+2
	TST.L	F2+2
	BEQ.S	CONT_EFFECT3
	MOVE.L	26(A6),F2+2
CONT_EFFECT3
	LEA		VOICE3(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT4
	BSR		DO_EFFECT
	MOVE.L	26(A6),V3+2
	TST.L	F3+2
	BEQ.S	CONT_EFFECT4
	MOVE.L	26(A6),F3+2
CONT_EFFECT4
	MOVEM.L	(SP)+,D4-D6/A4-A6
	RTS

DO_EFFECT
	MOVE.B	22(A6),D4
	BEQ.S	ARPEGGIO_ROUT
	CMP.B	#1,D4
	BEQ.S	PORTUP
	CMP.B	#2,D4
	BEQ.S	PORTDOWN
	RTS

PORTUP
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	SUB		D4,D5
	CMP		#$71,D5
	BPL.S	OK_PORTUP
	MOVEQ	#$71,D5
OK_PORTUP
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

PORTDOWN
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	ADD		D4,D5
	CMP		#$358,D5
	BMI.S	OK_PORTDOWN
	MOVE	#$358,D5
OK_PORTDOWN
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

ARPEGGIO_ROUT
	MOVE.B	21(A6),D4
	CMP.B	#1,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#2,D4
	BEQ.S	ARP_ROUT2
	CMP.B	#3,D4
	BEQ.S	ARP_ROUT3
	CMP.B	#4,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#5,D4
	BEQ.S	ARP_ROUT2
	RTS

ARP_ROUT1
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	LSR.B	#4,D4
	BRA.S	ARP_ROUT
ARP_ROUT2
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	AND.B	#$0F,D4
	BRA.S	ARP_ROUT
ARP_ROUT3
	MOVE	24(A6),D6
	BRA.S	END_ARP_ROUT2
ARP_ROUT
	ADD		D4,D4
	MOVE	24(A6),D5
	LEA		ARPEGGIO_DATA(PC),A4
ARP_LOOP
	CMP		(A4),D5
	BEQ.S	END_ARP_ROUT1
	LEA		2(A4),A4
	BRA.S	ARP_LOOP
END_ARP_ROUT1
	MOVE	(A4,D4),D6
END_ARP_ROUT2
	ADD		D6,D6
	ADD		D6,D6
	MOVE.L	(A5,D6),26(A6)
	ADDQ.B	#1,21(A6)
	RTS

RESTART
	MOVEM.L	(SP)+,D0-D1/A0-A5
	MOVE	#6,SPD+2 
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA		MUZEXX,A0
	ADD		SEQ,A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF,A0
	LEA		OFF,A1
	LEA		OFF,A2
	LEA		OFF,A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2
	BRA		PLAY

END_OF_MUZEXX
	RTS




FILENAME	DC.B	40,0
			DS.B	40
OFF			DC.L	0
SPEED		DC.B	0
POS			DC.B	0
TRK			DC.B	0
SEQ			DS.W	1
PAT			DS.W	1
NBR_INS		DS.W	1
FRQ			incbin 25_KHZ.FRQ
ARPEGGIO_DATA		DC.W	$0358,$0328,$02FA,$02D0,$02A6,$0280,$025C
			DC.W	$023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D
			DC.W	$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0
			DC.W	$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097
			DC.W	$008F,$0087,$007F,$0078,$0071,$0000,$0000,$0000

SVBL		DS.L	0
TIMERA		DS.L	1
SAVE_STACK	DS.L	1
			DS.L	128
STACK
SWITCH		DS.W	1
KEY_PRESS	DS.W	1
VOICE0		DS.L	8
VOICE1		DS.L	8
VOICE2		DS.L	8
VOICE3		DS.L	8
ADD_IN_PAT	DS.L	1
REGIS		DS.L	14
MU			DS.W 		10080
MUSIQUE_END		DS.L		10
MUSI			DS.L		0
INS			DS.L	32*4


pos1:	dc.l 0
pos2:	dc.l 0
pos3:	dc.l 0
pos4:	dc.l 0
pos5:	dc.l 0
pos6:	dc.l 0
pos7:	dc.l 0
pos8:	dc.l 0
pos9:	dc.l 0
pos10:	dc.l 0
pos11:	dc.l 0
pos12:	dc.l 0
pos13:	dc.l 0
pos14:	dc.l 0
z
	dc.b 1
	even
palimg	dc.w 0,$20,$30,$40,$60,$215,$757,$220,$333,$444,$555,$777,$700,$634,$577,$770
palhbl1
	dc.w $f,$f,$f,$f,$f,$f,$f,$f,7,7,$e,$e,6,6,$d,$d,5,5,$c,$c
	dc.w 4,4,$b,$b,3,3,$a,$a,2,2,9,9,1,1,8,8,0,0,-1
palhbl2
	dc.w $f,$f,$f,$f,$f,$f,$f,7,7,$e,$e,6,6,$d,$d,5,5,$c,$c,4,4
	dc.w $b,$b,3,3,$a,$a,2,2,9,9,1,1,8,8,0,0,0,-1
palhbl dc.l palhbl1
pospal dc.l 0
color  dc.w 0
wait	dc.b 0
	even
ecran2
	incbin img1.ste
ecran3	
	incbin anim2.pi1
anim1	incbin anim1.ste
h	equ	ecran3+66-32
H	equ	ecran3+66+22*160-32
hh	equ	ecran3+66+44*160-32
posh	dc.l	0
posm	dc.l	0
poss	dc.l	0
hand	
	dc.l	h,h,h,h,h,h,h,h,h,h,h,h,h,h,h,h,h,h,h,h
	dc.l	h,h+24,h+48,h+24
	dc.l	h,h+24,h+48,h+24
	dc.l	h,h+24,h+48,h+24
	dc.l	h,h+24,h+48,h+72,h+96
	dc.l	h+120,H,h+120,H,h+120,H,h+120,H
	dc.l	h+120,H,h+120,H,h+120,H,h+120,H
	dc.l	h+120,h+96,h+72,h+48,h+24
	dc.l	h,h+24,h+48,h+24
	dc.l	h,h+24,h+48,h+24
	dc.l	h,h+24,h+48,h+24
	dc.l	h,h+24,h+48,h+72,h+96
	dc.l	h+120,H,h+120,H,h+120,H,h+120,H
	dc.l	h+120,H,h+120,H,h+120,H,h+120,H
	dc.l	H+24,H+48,H+72,H+96,H+120
	dc.l	hh,hh+24,hh+48,hh+72,hh+96
	dc.l	hh+120,hh+96,hh+72,hh+48,hh+24
	dc.l	hh,hh+24,hh+48,hh+72,hh+96
	dc.l	hh+120,hh+96,hh+72,hh+48,hh+24
	dc.l	hh,hh+24,hh+48,hh+72,hh+96
	dc.l	hh+120,hh+96,hh+72,hh+48,hh+24
	dc.l	hh,hh+24,hh+48,hh+72,hh+96
	dc.l	hh+120,hh+96,hh+72,hh+48,hh+24
	dc.l	hh,hh+24,hh+48,hh+72,hh+96
	dc.l	hh+120,hh+96,hh+72,hh+48,hh+24
	dc.l	hh,hh+24,hh+48,hh+72,hh+96
	dc.l	hh+120,hh+96,hh+72,hh+48,hh+24
	dc.l	H+120,H+96,H+72,H+48,h+72
	dc.l	h+48,h+24,h,h,h,h,h,h
	dc.l	-1

	dc.l	h,h+24,h+48,h+72,h+96,h+120
	dc.l	H,H+24,H+48,H+72,H+96,H+120
	dc.l	hh,hh+24,hh+48,hh+72,hh+96,hh+120
	dc.l	-1
m	equ	ecran3+66+84*160-32
M	equ	anim1
monster
	dc.l	m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m,m
	dc.l   m,m,m,m,m,m
	dc.l   m,m,m,m,m,m
	dc.l   m,m,m,m,m
	dc.l	m+32,m+64,m+96,m+64,m+32,m+64,m+96,m+64,m+32,m+64,m+96,m+64,m+32,m+64,m+96,m+64,m+32
	dc.l   m,m,m,m,m,m,m,m,m,m,m
	dc.l   m,m,m,m,m,m,m,m,m,m
	dc.l	m+32,m+64,m+96,m+64,m+32,m+64,m+96,m+64,m+32,m+64,m+96,m+64,m+32,m+64,m+96,m+64,m+32
	dc.l   m,m,m,m,m
	dc.l   m,m,m,m,m
	dc.l	M+64,M+64,M+32,M+32,M+64,M+64,M+32,M+32
	dc.l	M+64,M+64,M+32,M+32,M+64,M+64,M+32,M+32
	dc.l	M+64,M+64,M+32,M+32,M+64,M+64,M+32,M+32
	dc.l	M+64,M+64,M+32,M+32,M+64,M+64,M+32,M+32
	dc.l	M+64,M+64,M+32,M+32,M+64,M+64,M+32,M+32
	dc.l	M+64,M+64,M+32,M+32,M+64,M+64,M+32,M+32
	dc.l	M+64,M+64,M+32,M+32,M+64,M+64,M+32,M+32
	dc.l   m,m,m,m,m,m,m,m,m,m,m,m
	dc.l	-1
s	equ	ecran3+66+66*160-32
scooter
	dc.l	s,s
	dc.l	s+16,s+32,s+48,s+64,s+80
	;dc.l	s+16,s+16,s+32,s+32,s+48,s+48,s+64,s+64,s+80,s+80
	dc.l	s,s,s,s
	dc.l	-1

tab1
	dcb.b 5*80
	dc.b -1
tab2	dcb.b 5*160
	dc.b -1
tab3	dcb.b 5*320
	dc.b -1
tab4	dcb.b 5*5
	dc.b -1
tab5	dcb.b 5*320
	dc.b -1
tab6	dcb.b 5*160
	dc.b -1
tab7	dcb.b 5*320
	dc.b -1
tab8	dcb.b 5*80
	dc.b -1
tab9	dcb.b 5*320
	dc.b -1 
tab10	dcb.b 5*320
	dc.b -1
tab11	dcb.b 5*320
	dc.b -1
tab12	dcb.b 5*320
	dc.b -1
tab13	dcb.b 5*320
	dc.b -1
tab14	dcb.b 5*320
	dc.b -1
txt	dc.b $1b,'EOoohh!  there is the second screen of',$d,$a
	dc.b '		   The Delirious III.',$d,$a
	dc.b 'And MY second code on STE.',$d,$a,$d,$a
	dc.b 'Always a soundtracker a 25 khz.',$d,$a
	dc.b 'But this time there is 13 scrolls.',$d,$a
	dc.b "It's really easy to programm cool demo",$d,$a
	dc.b "on a STE, and I have time left to put",$d,$a
	dc.b "something else, but I have no graph.",$d,$a,$d,$a
	dc.b "Graph and anim by ALF",$d,$a
	dc.b "Musix by  ?????",$d,$a
	dc.b "Code by Axel F.",$d,$a,$d,$a
	dc.b " Burst the ESC key",0
	even
txt2	dc.b $1b,'E',0
	even


	
	end


	
