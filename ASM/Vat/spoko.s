*************************************
* Gejm baj Vat of kors!!! NOT DONE! *
*************************************
**************Last Changes: 94.03-23*
Begin:	opt	x+
	lea	$80000,a7
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#$40,$16e.w ;kolor
	move.b	#$12,$fffffc02.w
	;clr.b	$484.w
	bsr	Rez
Loop
	bsr	Vbl
	bsr	Vbl
	bsr	Vbl
	bsr	Move
	bra.s	Loop

Move
	lea	remov1(pc),a0
	lea	(a0),a3
	moveq	#7,d7
	moveq	#$66,d0
.loop	move.l	(a0)+,a1
	addq.l	#4,a0
	move.b	d0,(a1)
	dbf	d7,.loop
	lea	LstKeyz(pc),a4
	moveq	#0,d3
	move.b	(a4),d3
	lsl.w	#3,d3
	move.l	(a3,d3.w),a0
	move.b	#$60,(a0)
	move.l	4(a3,d3.w),a0
	move.b	#$60,(a0)
	lea	16*2(a3),a3
	moveq	#0,d4
	move.b	$fffffc02.w,d4
	lea	PLAYER1(pc),a0
	cmp.b	#$48,d4
p01	bne.s	NoUp1
	move.b	#0,(a4)
	sub.w	#160,2(a0)
	bra.s	Jmp1Dalej
NoUp1	cmp.b	#$50,d4
p11	bne.s	NoDown1
	move.b	#1,(a4)
	add.w	#160,2(a0)
	bra.s	Jmp1Dalej
NoDown1	cmp.b	#$4d,d4
p21	bne.s	NoRght1
	move.b	#2,(a4)
	addq.w	#1,(a0)
	bra.s	Jmp1Dalej
NoRght1	cmp.b	#$4b,d4
p31	bne.s	NoLeft1
	move.b	#3,(a4)
	subq.w	#1,(a0)
	bra.s	Jmp1Dalej
NoLeft1	lea	NoKeyTab(pc),a1
	moveq	#0,d0
	move.b	(a4),d0
	add.w	d0,d0
	move.w	(a1,d0.w),d0
	btst	#0,d0
	bne.s	iksy1
	add.w	d0,2(a0)
	bra.s	Jmp1Dalej
iksy1	add.w	d0,(a0)

Jmp1Dalej:
	moveq	#0,d3
	move.b	1(a4),d3
	lsl.w	#3,d3
	move.l	(a3,d3.w),a1
	move.b	#$60,(a1)
	move.l	4(a3,d3.w),a1
	move.b	#$60,(a1)
	cmp.b	#$10,d4	;A
p02	bne.s	NoUp2
	move.b	#0,1(a4)
	sub.w	#160,6(a0)
	bra.s	Jmp2Dalej
NoUp2	cmp.b	#$1e,d4	;Q
p12	bne.s	NoDown2
	move.b	#1,1(a4)
	add.w	#160,6(a0)
	bra.s	Jmp2Dalej
NoDown2	cmp.b	#$2e,d4	;X
p22	bne.s	NoRght2
	move.b	#2,1(a4)
	addq.w	#1,4(a0)
	bra.s	Jmp2Dalej
NoRght2	cmp.b	#$2d,d4	;C
p32	bne.s	NoLeft2
	move.b	#3,1(a4)
	subq.w	#1,4(a0)
	bra.s	Jmp2Dalej
NoLeft2	lea	NoKeyTab(pc),a1
	moveq	#0,d0
	move.b	1(a4),d0
	add.w	d0,d0
	move.w	(a1,d0.w),d0
	btst	#0,d0
	bne.s	iksy2
	add.w	d0,6(a0)
	bra.s	Jmp2Dalej
iksy2	add.w	d0,4(a0)

Jmp2Dalej:
	lea	PLAYER1(pc),a0
	move.l	Scr(pc),a2
	lea	2(a2),a3
	lea	Pixy(pc),a4
Get	movem.w	(a0),d0-d3
	add.w	d1,a2
	add.w	d3,a3
	move.w	d0,d1
	move.w	d2,d3
	and.w	#$f,d1
	add.w	d1,d1
	move.w	(a4,d1.w),d1
	and.w	#$f,d3
	add.w	d3,d3
	move.w	(a4,d3.w),d3
	lsr.w	#1,d0
	lsr.w	#1,d2
	and.w	#$f8,d0
	and.w	#$f8,d2
	add.w	d0,a2
	add.w	d2,a3
	move.w	(a2),d0
	or.w	2(a2),d0
	or.w	4(a2),d0
	or.w	6(a2),d0
	move.w	-2(a3),d2
	or.w	(a3),d2
	or.w	2(a3),d2
	or.w	4(a3),d2
	move.b	#0,ccr
********** CHECK PLAYER ONE *********
	and.w	d1,d0
	bne.s	DeadPL1
KamBek1	or.w	d1,(a2)
********** CHECK PLAYER TWO *********
	move.b	#0,ccr
	and.w	d3,d2
	bne.s	DeadPL2
KamBek2	or.w	d3,(a3)
	rts






****** IF PLAYERS DEAD THEN... ******

DeadPL1
	move.l	Scr(pc),a0
	move.l	#$ffff0000,(a0)
	move.w	#0,4(a0)
.kl	stop	#$2300
	cmp.b	#$39,$fffffc02.w
	bne.s	.kl
	move.b	#7,$484.w
	move.b	#8,$fffffc02.w
	clr.l	(a7)
	trap	#1
DeadPL2
	move.l	Scr(pc),a0
	move.l	#$ffff,152(a0)
	move.l	#0,156(a0)
.kl	stop	#$2300
	cmp.b	#$39,$fffffc02.w
	bne.s	.kl
	move.b	#7,$484.w
	move.b	#8,$fffffc02.w
	clr.l	(a7)
	trap	#1
Vbl
	move.w	$468.w,d0
Sync	cmp.w	$468.w,d0
	beq.s	Sync
	stop	#$2300
	cmp.b	#$39,$fffffc02.w
	bne.s	.noend
	move.b	#7,$484.w
	clr.l	(a7)
	trap	#1
.noend	rts
Rez
	move.l	Scr(pc),a0
	move.l	a0,$ffff8200.w
	clr.b	$ffff8260.w
	move.l	d0,$44e.w
	move.w	#2040,d7
	moveq	#0,d0
.ClrScr	dcb.w	$20c0,8
	dbf	d7,.ClrScr
	move.l	Scr(pc),a0
	lea	(a0),a1
	moveq	#19,d7
	moveq	#-1,d0
edox	or.w	d0,4(a0)
	or.w	d0,199*160+4(a0)
	addq.w	#8,a0
	dbf	d7,edox
	moveq	#1,d0
	move.w	#$8000,d1
	move.w	#199,d7
edoy	or.w	d1,4(a1)
	or.w	d0,156(a1)
	lea	160(a1),a1
	dbf	d7,edoy
	clr.b	$ffff8260.w
	rts
Scr	dc.l	$70000,$70080
PLAYER1	dc.w	106,100*160
	dc.w	212,100*160
Pixy	dc.w	$8000,$4000,$2000,$1000
	dc.w	$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010
	dc.w	$0008,$0004,$0002,$0001
LstKeyz	dc.b	$02,$03	;,$02,$03
NoKeyTab dc.w	-160,160,1,-1
remov1	dc.l	p11,p01,p01,p11,p31,p21,p21,p31
remov2	dc.l	p12,p02,p02,p12,p32,p22,p22,p32
